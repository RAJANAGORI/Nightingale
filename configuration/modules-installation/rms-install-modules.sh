#!/usr/bin/env bash

###############################################################################
# Runtime Mobile Security (RMS) Installation Script
# Description: Installs and configures RMS for mobile security testing
# Author: Raja Nagori
# Email: raja.nagori@owasp.org
# License: GPL-3.0
###############################################################################

# Enable strict error handling
set -euo pipefail

# Set secure PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

###############################################################################
# Configuration
###############################################################################

readonly TOOLS_MOBILE_VAPT="${TOOLS_MOBILE_VAPT:-/home/tools_mobile_vapt}"
readonly RMS_DIR="${TOOLS_MOBILE_VAPT}/rms"
readonly PM2_CONFIG="pm2-rms.json"
readonly LOG_FILE="/tmp/rms-installation.log"

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
    log_error "Check $LOG_FILE for details"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Installation Functions
###############################################################################

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if RMS directory exists
    if [[ ! -d "$RMS_DIR" ]]; then
        error_exit "RMS directory not found: $RMS_DIR"
    fi
    
    # Check if npm is installed
    if ! command_exists npm; then
        error_exit "npm is not installed. Please install Node.js first."
    fi
    
    # Check if pm2 is installed
    if ! command_exists pm2; then
        log_warn "pm2 is not installed globally, attempting to install..."
        npm install -g pm2 >> "$LOG_FILE" 2>&1 || error_exit "Failed to install pm2"
    fi
    
    log_info "Prerequisites check passed"
}

# Install RMS dependencies
install_rms_dependencies() {
    log_info "Installing RMS dependencies..."
    
    # Change to RMS directory
    cd "$RMS_DIR" || error_exit "Failed to change to RMS directory: $RMS_DIR"
    
    # Check if package.json exists
    if [[ ! -f "package.json" ]]; then
        error_exit "package.json not found in $RMS_DIR"
    fi
    
    # Install npm dependencies
    log_info "Running npm install (this may take a few minutes)..."
    
    if npm install >> "$LOG_FILE" 2>&1; then
        log_info "RMS dependencies installed successfully"
    else
        error_exit "Failed to install RMS dependencies"
    fi
    
    # Clean npm cache to save space
    npm cache clean --force >> "$LOG_FILE" 2>&1 || log_warn "Failed to clean npm cache"
}

# Start RMS with PM2
start_rms_with_pm2() {
    log_info "Starting RMS with PM2..."
    
    # Verify we're in the right directory
    cd "$RMS_DIR" || error_exit "Failed to change to RMS directory: $RMS_DIR"
    
    # Check if PM2 config exists
    if [[ ! -f "$PM2_CONFIG" ]]; then
        error_exit "PM2 configuration file not found: $PM2_CONFIG"
    fi
    
    # Stop any existing RMS instances
    log_info "Stopping existing RMS instances..."
    pm2 stop "$PM2_CONFIG" >> "$LOG_FILE" 2>&1 || log_info "No existing instances to stop"
    pm2 delete "$PM2_CONFIG" >> "$LOG_FILE" 2>&1 || log_info "No existing instances to delete"
    
    # Start RMS with PM2
    log_info "Starting RMS..."
    
    if pm2 start "$PM2_CONFIG" >> "$LOG_FILE" 2>&1; then
        log_info "RMS started successfully with PM2"
    else
        error_exit "Failed to start RMS with PM2"
    fi
    
    # Save PM2 process list
    if pm2 save >> "$LOG_FILE" 2>&1; then
        log_info "PM2 process list saved"
    else
        log_warn "Failed to save PM2 process list"
    fi
}

# Verify RMS installation
verify_installation() {
    log_info "Verifying RMS installation..."
    
    # Check if PM2 is running RMS
    if pm2 list | grep -q "rms"; then
        log_info "RMS is running under PM2"
        
        # Display PM2 status
        echo ""
        pm2 list | tee -a "$LOG_FILE"
        echo ""
    else
        log_warn "RMS does not appear to be running"
    fi
}

# Display installation summary
display_summary() {
    echo ""
    echo "============================================"
    echo "  RMS Installation Complete"
    echo "============================================"
    echo ""
    echo "Details:"
    echo "  RMS Directory: $RMS_DIR"
    echo "  PM2 Config: $PM2_CONFIG"
    echo ""
    echo "Useful PM2 Commands:"
    echo "  pm2 list          - List all processes"
    echo "  pm2 logs rms      - View RMS logs"
    echo "  pm2 restart rms   - Restart RMS"
    echo "  pm2 stop rms      - Stop RMS"
    echo "  pm2 monit         - Monitor processes"
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "Starting RMS (Runtime Mobile Security) installation..."
    log_info "Log file: $LOG_FILE"
    echo ""
    
    # Step 1: Check prerequisites
    check_prerequisites
    
    # Step 2: Install RMS dependencies
    install_rms_dependencies
    
    # Step 3: Start RMS with PM2
    start_rms_with_pm2
    
    # Step 4: Verify installation
    verify_installation
    
    # Step 5: Display summary
    display_summary
    
    log_info "RMS installation completed successfully!"
}

# Execute main function
main "$@"