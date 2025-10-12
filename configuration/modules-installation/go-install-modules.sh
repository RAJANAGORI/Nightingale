#!/usr/bin/env bash
###############################################################################
# Nightingale Go Modules Installation Script
# Description: Installs Go-based security tools using go install
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
# Usage: ./go-install-modules.sh
###############################################################################

# Strict error handling
set -euo pipefail

# Secure PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Configuration
readonly SCRIPT_NAME="$(basename "${0}")"
readonly LOG_FILE="/var/log/nightingale-go-install.log"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

###############################################################################
# Logging Functions
###############################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "${LOG_FILE}"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${LOG_FILE}"
}

error_exit() {
    log_error "$1"
    exit 1
}

###############################################################################
# Utility Functions
###############################################################################

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Extract tool name from Go package path
extract_tool_name() {
    local package=$1
    # Remove @latest and extract binary name
    local tool_path="${package%@*}"
    basename "${tool_path}" | cut -d'/' -f1
}

###############################################################################
# Installation Functions
###############################################################################

# Function to install a Go tool
install_go_tool() {
    local package=$1
    local tool_name
    tool_name=$(extract_tool_name "${package}")
    
    log_info "Installing ${tool_name}..."
    
    # Set GOBIN if not set
    export GOBIN="${GOPATH:-$HOME/go}/bin"
    
    # Install the tool
    if go install "${package}" 2>&1 | tee -a "${LOG_FILE}"; then
        # Verify installation
        local binary_name="${tool_name}"
        if command -v "${binary_name}" >/dev/null 2>&1; then
            log_success "✓ ${tool_name} installed successfully"
            return 0
        else
            log_warn "✓ ${tool_name} installed but not found in PATH"
            return 0
        fi
    else
        log_error "✗ Failed to install ${tool_name}"
        return 1
    fi
}

###############################################################################
# Main Installation Process
###############################################################################

main() {
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Nightingale Go Modules Installation Started"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Prerequisites check
    log_info "Checking prerequisites..."
    command_exists go || error_exit "Go is not installed. Please install Go first."
    log_success "✓ Go is installed: $(go version)"
    
    # Verify GOPATH
    if [[ -z "${GOPATH:-}" ]]; then
        export GOPATH="$HOME/go"
        log_warn "GOPATH not set, using default: ${GOPATH}"
    fi
    log_info "GOPATH: ${GOPATH}"
    
    # Create GOBIN directory if it doesn't exist
    mkdir -p "${GOPATH}/bin"
    
    # Ensure GOPATH/bin is in PATH
    if [[ ":$PATH:" != *":${GOPATH}/bin:"* ]]; then
        export PATH="${PATH}:${GOPATH}/bin"
        log_info "Added ${GOPATH}/bin to PATH"
    fi
    
    # Track installation results
    local total_tools=0
    local successful_tools=0
    local failed_tools=0
    
    # List of Go security tools to install
    # Organized by category for better documentation
    local -a tools=(
        # OSINT & Reconnaissance
        "github.com/owasp-amass/amass/v3/...@latest"
        "github.com/tomnomnom/assetfinder@latest"
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "github.com/tomnomnom/httprobe@latest"
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"
        "github.com/lc/gau/v2/cmd/gau@latest"
        "github.com/tomnomnom/waybackurls@latest"
        
        # Fuzzing & Scanning
        "github.com/ffuf/ffuf@latest"
        "github.com/OJ/gobuster/v3@latest"
        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
        "github.com/projectdiscovery/katana/cmd/katana@latest"
        "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
        
        # Utilities
        "github.com/tomnomnom/gf@latest"
        "github.com/tomnomnom/qsreplace@latest"
        "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    )
    
    log_info ""
    log_info "═══ Installing Go Security Tools (${#tools[@]} total) ═══"
    log_info ""
    
    # Install each tool
    for package in "${tools[@]}"; do
        ((total_tools++))
        if install_go_tool "${package}"; then
            ((successful_tools++))
        else
            ((failed_tools++))
        fi
        # Add small delay to avoid rate limiting
        sleep 1
    done
    
    # -------------------------------------------------------------------------
    # Final Configuration
    # -------------------------------------------------------------------------
    log_info ""
    log_info "Configuring environment..."
    
    # Add GOPATH/bin to bashrc if not already present
    if ! grep -q 'GOPATH/bin' ~/.bashrc 2>/dev/null; then
        {
            echo ''
            echo '# Go binaries'
            echo 'export GOPATH="${GOPATH:-$HOME/go}"'
            echo 'export PATH="$PATH:$GOPATH/bin"'
        } >> ~/.bashrc
        log_success "Added GOPATH/bin to ~/.bashrc"
    fi
    
    # Clean Go cache to save space
    log_info "Cleaning Go build cache..."
    go clean -cache 2>/dev/null || true
    go clean -modcache 2>/dev/null || log_warn "Could not clean module cache (may require permissions)"
    
    # -------------------------------------------------------------------------
    # Installation Summary
    # -------------------------------------------------------------------------
    log_info ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Installation Summary"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Total tools: ${total_tools}"
    log_success "Successfully installed: ${successful_tools}"
    if [[ ${failed_tools} -gt 0 ]]; then
        log_warn "Failed installations: ${failed_tools}"
    fi
    log_info "Success rate: $((successful_tools * 100 / total_tools))%"
    log_info "Installation directory: ${GOPATH}/bin"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Display installed tools
    log_info ""
    log_info "Installed Go tools:"
    ls -1 "${GOPATH}/bin" 2>/dev/null | head -20 | while read -r binary; do
        log_info "  • ${binary}"
    done
    
    if [[ ${failed_tools} -eq 0 ]]; then
        log_success ""
        log_success "✓ All Go security tools installed successfully!"
        log_success ""
        return 0
    else
        log_warn ""
        log_warn "Some tools failed to install. Check ${LOG_FILE} for details."
        log_warn ""
        return 1
    fi
}

# Execute main function
main "$@"