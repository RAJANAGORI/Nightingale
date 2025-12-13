#!/usr/bin/env bash

###############################################################################
# Node.js Installation Script via NVM
# Description: Installs Node.js using NVM (Node Version Manager)
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

readonly NVM_DIR="/root/.nvm"
readonly NVM_REPO="https://github.com/nvm-sh/nvm.git"
readonly NODE_VERSION="${NODE_VERSION:-v16.14.0}"
readonly LOG_FILE="/tmp/node-installation.log"

# Global NPM packages to install
readonly NPM_PACKAGES=(
    "pm2"
    "localtunnel"
)

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
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
    
    if ! command_exists git; then
        error_exit "git is not installed. Please install git first."
    fi
    
    if ! command_exists curl; then
        log_warn "curl is not installed, some features may not work"
    fi
    
    log_info "Prerequisites check passed"
}

# Clone NVM repository
clone_nvm() {
    log_info "Cloning NVM repository..."
    
    # Remove existing NVM directory if it exists
    if [[ -d "$NVM_DIR" ]]; then
        log_warn "Existing NVM directory found, removing..."
        rm -rf "$NVM_DIR" || error_exit "Failed to remove existing NVM directory"
    fi
    
    # Clone NVM with depth 1 for faster download
    if git clone --depth 1 "$NVM_REPO" "$NVM_DIR" >> "$LOG_FILE" 2>&1; then
        log_info "NVM repository cloned successfully"
    else
        error_exit "Failed to clone NVM repository"
    fi
    
    # Set proper permissions (avoid 777 for security)
    log_info "Setting permissions..."
    chmod -R 755 "$NVM_DIR" || error_exit "Failed to set permissions"
    
    # Remove .git directory to save space
    rm -rf "${NVM_DIR}/.git" 2>/dev/null || true
}

# Install NVM
install_nvm() {
    log_info "Installing NVM..."
    
    # Check if install script exists
    if [[ ! -f "${NVM_DIR}/install.sh" ]]; then
        error_exit "NVM install script not found"
    fi
    
    # Make install script executable
    chmod +x "${NVM_DIR}/install.sh" || error_exit "Failed to make install script executable"
    
    # Run NVM installation
    if bash "${NVM_DIR}/install.sh" >> "$LOG_FILE" 2>&1; then
        log_info "NVM installed successfully"
    else
        error_exit "NVM installation failed"
    fi
    
    # Source NVM to make it available in current session
    # shellcheck disable=SC1091
    if [[ -f "${NVM_DIR}/nvm.sh" ]]; then
        export NVM_DIR
        source "${NVM_DIR}/nvm.sh" || log_warn "Failed to source NVM"
    else
        error_exit "NVM script not found after installation"
    fi
}

# Install Node.js
install_nodejs() {
    log_info "Installing Node.js ${NODE_VERSION}..."
    
    # Ensure NVM is loaded
    # shellcheck disable=SC1091
    export NVM_DIR
    if [[ -f "${NVM_DIR}/nvm.sh" ]]; then
        source "${NVM_DIR}/nvm.sh" || error_exit "Failed to source NVM"
    else
        error_exit "NVM not properly installed"
    fi
    
    # Install specified Node.js version
    if nvm install "$NODE_VERSION" >> "$LOG_FILE" 2>&1; then
        log_info "Node.js ${NODE_VERSION} installed successfully"
    else
        error_exit "Failed to install Node.js ${NODE_VERSION}"
    fi
    
    # Set as default version
    if nvm alias default "$NODE_VERSION" >> "$LOG_FILE" 2>&1; then
        log_info "Set Node.js ${NODE_VERSION} as default"
    else
        log_warn "Failed to set default Node.js version"
    fi
    
    # Use the installed version
    nvm use "$NODE_VERSION" >> "$LOG_FILE" 2>&1 || log_warn "Failed to switch to Node.js ${NODE_VERSION}"
}

# Install global NPM packages
install_npm_packages() {
    log_info "Installing global NPM packages..."
    
    # Ensure Node.js is available
    if ! command_exists npm; then
        error_exit "npm command not found. Node.js installation may have failed."
    fi
    
    # Install each package
    local failed_packages=()
    
    for package in "${NPM_PACKAGES[@]}"; do
        log_info "Installing ${package}..."
        
        if npm install -g "$package" >> "$LOG_FILE" 2>&1; then
            log_info "${package} installed successfully"
        else
            log_error "Failed to install ${package}"
            failed_packages+=("$package")
        fi
    done
    
    # Report any failures
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warn "Failed to install: ${failed_packages[*]}"
    else
        log_info "All NPM packages installed successfully"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Check Node.js
    if command_exists node; then
        local node_version
        node_version=$(node --version)
        log_info "Node.js version: $node_version"
    else
        log_warn "Node.js command not found"
    fi
    
    # Check NPM
    if command_exists npm; then
        local npm_version
        npm_version=$(npm --version)
        log_info "npm version: $npm_version"
    else
        log_warn "npm command not found"
    fi
    
    # Check installed packages
    for package in "${NPM_PACKAGES[@]}"; do
        if command_exists "$package"; then
            log_info "${package}: installed"
        else
            log_warn "${package}: not found in PATH"
        fi
    done
}

# Display installation summary
display_summary() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  Node.js Installation Complete${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "Details:"
    echo "  NVM Directory: $NVM_DIR"
    echo "  Node Version: $NODE_VERSION"
    echo "  NPM Packages: ${NPM_PACKAGES[*]}"
    echo ""
    echo "To use NVM in your shell, run:"
    echo "  export NVM_DIR=\"$NVM_DIR\""
    echo "  source \"\$NVM_DIR/nvm.sh\""
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
}

###############################################################################
# Main Execution
###############################################################################

main() {
    log_info "Starting Node.js installation via NVM..."
    log_info "Log file: $LOG_FILE"
    echo ""
    
    # Step 1: Check prerequisites
    check_prerequisites
    
    # Step 2: Clone NVM
    clone_nvm
    
    # Step 3: Install NVM
    install_nvm
    
    # Step 4: Install Node.js
    install_nodejs
    
    # Step 5: Install NPM packages
    install_npm_packages
    
    # Step 6: Verify installation
    verify_installation
    
    # Step 7: Display summary
    display_summary
    
    log_info "Node.js installation completed successfully!"
}

# Execute main function
main "$@"