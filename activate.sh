#!/usr/bin/env bash

###############################################################################
# Nightingale Module Activation Script
# Description: Activates and installs Python and Go modules
# Author: Raja Nagori
# Email: raja.nagori@owasp.org
# License: GPL-3.0
###############################################################################

# Enable strict error handling
set -euo pipefail

# Trap errors and cleanup
trap 'error_exit "Script failed at line $LINENO"' ERR

###############################################################################
# Configuration
###############################################################################

# Set secure PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Environment variables with defaults
SHELLS="${SHELLS:-/home/.shells}"
PYTHON_SCRIPT="${SHELLS}/python-install-modules.sh"
GO_SCRIPT="${SHELLS}/go-install-modules.sh"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

###############################################################################
# Utility Functions
###############################################################################

# Print colored log messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Error exit function
error_exit() {
    log_error "$1"
    exit 1
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate script exists and is executable
validate_script() {
    local script_path="$1"
    local script_name="$2"
    
    if [[ ! -f "$script_path" ]]; then
        error_exit "$script_name script not found at: $script_path"
    fi
    
    if [[ ! -r "$script_path" ]]; then
        error_exit "$script_name script is not readable: $script_path"
    fi
    
    return 0
}

# Check if a tool is already installed
is_installed() {
    local check_command="$1"
    
    if [[ -z "$check_command" ]]; then
        log_warn "Empty check command provided"
        return 1
    fi
    
    if eval "$check_command" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Activation Functions
###############################################################################

# Activate Python modules
activate_python() {
    log_info "Starting Python modules activation..."
    log_info "This may take several minutes. Please wait..."
    
    # Validate script exists
    validate_script "$PYTHON_SCRIPT" "Python"
    
    # Convert line endings if dos2unix is available
    if command_exists dos2unix; then
        log_info "Converting line endings..."
        dos2unix "$PYTHON_SCRIPT" >/dev/null 2>&1 || \
            log_warn "Failed to convert line endings, continuing anyway..."
    fi
    
    # Make script executable
    chmod +x "$PYTHON_SCRIPT" || error_exit "Failed to make Python script executable"
    
    # Execute the script
    log_info "Installing Python modules..."
    
    if command_exists pv; then
        # With progress indicator
        pv -qL 1 "$PYTHON_SCRIPT" | bash || error_exit "Python module installation failed"
    else
        # Without progress indicator
        bash "$PYTHON_SCRIPT" || error_exit "Python module installation failed"
    fi
    
    log_info "Python modules activation completed successfully"
    return 0
}

# Activate Go modules
activate_go() {
    log_info "Starting Go modules activation..."
    log_info "This may take several minutes. Please wait..."
    
    # Check if Go is installed
    if ! command_exists go; then
        error_exit "Go is not installed. Please install Go first."
    fi
    
    # Validate script exists
    validate_script "$GO_SCRIPT" "Go"
    
    # Convert line endings if dos2unix is available
    if command_exists dos2unix; then
        log_info "Converting line endings..."
        dos2unix "$GO_SCRIPT" >/dev/null 2>&1 || \
            log_warn "Failed to convert line endings, continuing anyway..."
    fi
    
    # Make script executable
    chmod +x "$GO_SCRIPT" || error_exit "Failed to make Go script executable"
    
    # Execute the script
    log_info "Installing Go modules..."
    
    if command_exists pv; then
        # With progress indicator
        pv -qL 1 "$GO_SCRIPT" | bash || error_exit "Go module installation failed"
    else
        # Without progress indicator
        bash "$GO_SCRIPT" || error_exit "Go module installation failed"
    fi
    
    log_info "Go modules activation completed successfully"
    return 0
}

# Activate all modules
activate_all() {
    log_info "Activating all modules (Python and Go)..."
    
    activate_python
    echo ""
    activate_go
    
    log_info "All modules activated successfully!"
    return 0
}

# List available tools (placeholder - can be expanded)
list_tools() {
    echo "Available Nightingale Tools:"
    echo ""
    echo "Web Application VAPT:"
    echo "  - sqlmap, nuclei, subfinder, httpx, ffuf, gobuster"
    echo "  - dirsearch, amass, arjun, gau, waybackurls"
    echo ""
    echo "Network VAPT:"
    echo "  - nmap, masscan, naabu, rustscan"
    echo ""
    echo "Mobile VAPT:"
    echo "  - adb, apktool, jadx, mobsf, frida, objection"
    echo ""
    echo "OSINT:"
    echo "  - theHarvester, reconspider, recon-ng, metagoofil"
    echo ""
    echo "Forensics:"
    echo "  - binwalk, steghide, exiftool, foremost"
    echo ""
    echo "For more details, visit: https://github.com/RAJANAGORI/Nightingale/wiki"
}

# Display help message
show_help() {
    cat << EOF
Nightingale Module Activation Script

USAGE:
    $(basename "$0") [OPTION]

OPTIONS:
    python      Activate Python modules
    go          Activate Go modules
    all         Activate all modules (Python + Go)
    --list      List available tools
    --help      Show this help message
    --version   Show version information

EXAMPLES:
    $(basename "$0") python
    $(basename "$0") go
    $(basename "$0") all

ENVIRONMENT VARIABLES:
    SHELLS      Path to scripts directory (default: /home/.shells)

For more information, visit: https://github.com/RAJANAGORI/Nightingale
EOF
}

# Display version information
show_version() {
    echo "Nightingale Activation Script v1.0.0"
    echo "Part of: Nightingale - Docker for Pentesters"
    echo "Author: Raja Nagori"
    echo "License: GPL-3.0"
}

###############################################################################
# Main Execution
###############################################################################

main() {
    # Check if no arguments provided
    if [[ $# -eq 0 ]]; then
        log_error "No option provided"
        echo ""
        show_help
        exit 1
    fi
    
    # Parse command line arguments
    case "$1" in
        python)
            activate_python
            ;;
        go)
            activate_go
            ;;
        all)
            activate_all
            ;;
        --list|-l)
            list_tools
            ;;
        --help|-h)
            show_help
            ;;
        --version|-v)
            show_version
            ;;
        *)
            log_error "Invalid option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"