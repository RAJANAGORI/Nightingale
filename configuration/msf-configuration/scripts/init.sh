#!/usr/bin/env bash

###############################################################################
# Metasploit PostgreSQL Initialization Script
# Description: Initializes PostgreSQL for Metasploit Framework
# Author: Raja Nagori
# Email: raja.nagori@owasp.org
# License: GPL-3.0
###############################################################################

# Enable strict error handling
set -euo pipefail

# Set secure PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

###############################################################################
# Configuration
###############################################################################

readonly PG_PID_DIR="/var/run/postgresql"
readonly PG_PID_PATTERN="${PG_PID_DIR}/*.pid"
readonly PG_INIT_SCRIPT="/etc/init.d/postgresql"
readonly LOG_FILE="/tmp/postgresql-init.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

###############################################################################
# Utility Functions
###############################################################################

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE" >&2
}

error_exit() {
    log_error "$1"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# PostgreSQL Functions
###############################################################################

# Clean up stale PID files
cleanup_pid_files() {
    log_info "Cleaning up stale PostgreSQL PID files..."
    
    if [[ ! -d "$PG_PID_DIR" ]]; then
        log_warn "PostgreSQL PID directory not found: $PG_PID_DIR"
        mkdir -p "$PG_PID_DIR" || log_warn "Failed to create PID directory"
        return 0
    fi
    
    # Remove all PID files safely
    if compgen -G "$PG_PID_PATTERN" > /dev/null 2>&1; then
        rm -f "$PG_PID_PATTERN" && log_info "PID files removed" || log_warn "Failed to remove some PID files"
    else
        log_info "No PID files to clean up"
    fi
}

# Start PostgreSQL service
start_postgresql() {
    log_info "Starting PostgreSQL service..."
    
    # Check if init script exists
    if [[ ! -f "$PG_INIT_SCRIPT" ]]; then
        error_exit "PostgreSQL init script not found: $PG_INIT_SCRIPT"
    fi
    
    # Check if init script is executable
    if [[ ! -x "$PG_INIT_SCRIPT" ]]; then
        log_warn "PostgreSQL init script is not executable, attempting to fix..."
        chmod +x "$PG_INIT_SCRIPT" || error_exit "Failed to make init script executable"
    fi
    
    # Start PostgreSQL
    if "$PG_INIT_SCRIPT" start >> "$LOG_FILE" 2>&1; then
        log_info "PostgreSQL started successfully"
    else
        error_exit "Failed to start PostgreSQL. Check $LOG_FILE for details"
    fi
    
    # Wait for PostgreSQL to be ready
    log_info "Waiting for PostgreSQL to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if command_exists pg_isready && pg_isready -q 2>/dev/null; then
            log_info "PostgreSQL is ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        sleep 1
    done
    
    log_warn "PostgreSQL may not be fully ready, continuing anyway..."
    return 0
}

# Verify PostgreSQL is running
verify_postgresql() {
    log_info "Verifying PostgreSQL status..."
    
    if command_exists pg_isready; then
        if pg_isready -q 2>/dev/null; then
            log_info "PostgreSQL is running and accepting connections"
            return 0
        else
            log_warn "PostgreSQL might not be accepting connections"
            return 1
        fi
    else
        log_warn "pg_isready command not found, skipping verification"
        return 0
    fi
}

# Display PostgreSQL connection info
display_info() {
    log_info "PostgreSQL initialized for Metasploit Framework"
    echo ""
    echo "Connection Details:"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: msf"
    echo "  User: msf"
    echo ""
    echo "Starting interactive shell..."
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "Initializing PostgreSQL for Metasploit Framework..."
    echo "Log file: $LOG_FILE"
    echo ""
    
    # Step 1: Clean up PID files
    cleanup_pid_files
    
    # Step 2: Start PostgreSQL
    start_postgresql
    
    # Step 3: Verify PostgreSQL is running
    verify_postgresql || log_warn "PostgreSQL verification failed, but continuing..."
    
    # Step 4: Display information
    display_info
    
    # Step 5: Start interactive shell
    log_info "Starting bash shell..."
    exec /bin/bash
}

# Execute main function
main "$@"