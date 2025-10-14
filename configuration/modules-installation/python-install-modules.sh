#!/usr/bin/env bash
###############################################################################
# Nightingale Python Modules Installation Script
# Description: Installs Python-based security tools using pipx and pip
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL 3.0
# Usage: ./python-install-modules.sh
###############################################################################

# Strict error handling
# Note: We use set -eo pipefail (not -u) to allow checking for unset variables gracefully
set -eo pipefail

# Secure PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Configuration
readonly SCRIPT_NAME="$(basename "${0}")"
readonly LOG_FILE="/var/log/nightingale-python-install.log"

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

# Validate directory exists
validate_directory() {
    local dir=$1
    if [[ ! -d "${dir}" ]]; then
        log_error "Directory not found: ${dir}"
        return 1
    fi
    return 0
}

###############################################################################
# Installation Functions
###############################################################################

# Function to install a tool using pipx and a requirements file
install_tool_with_pipx() {
    local tool_dir=$1
    local requirements_file=$2
    local tool_name
    tool_name=$(basename "${tool_dir}")
    
    # Validate directory exists
    if [[ ! -d "${tool_dir}" ]]; then
        log_info "${tool_name} directory not found, skipping..."
        return 1
    fi
    
    log_info "Installing ${tool_name}..."
    
    # Change to tool directory safely
    if ! cd "${tool_dir}" 2>/dev/null; then
        log_warn "Cannot access ${tool_name} directory"
        return 1
    fi
    
    # Check if requirements file exists
    if [[ ! -f "${requirements_file}" ]]; then
        log_warn "Requirements file not found: ${requirements_file}"
        cd - >/dev/null || true
        return 1
    fi
    
    # Install packages from requirements file
    local failed_packages=()
    while IFS= read -r package || [[ -n "${package}" ]]; do
        # Skip empty lines and comments
        [[ -z "${package}" || "${package}" =~ ^[[:space:]]*# ]] && continue
        
        log_info "  Installing package: ${package}"
        if pipx install "${package}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "  ✓ ${package} installed"
        else
            log_warn "  ✗ Failed to install ${package}"
            failed_packages+=("${package}")
        fi
    done < "${requirements_file}"
    
    # Return to previous directory
    cd - >/dev/null || true
    
    # Report results
    if [[ ${#failed_packages[@]} -eq 0 ]]; then
        log_success "${tool_name} installation completed successfully"
        return 0
    else
        log_warn "${tool_name} completed with ${#failed_packages[@]} failed packages: ${failed_packages[*]}"
        return 1
    fi
}

###############################################################################
# Main Installation Process
###############################################################################

main() {
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Nightingale Python Modules Installation Started"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Track installation results
    local total_tools=0
    local successful_tools=0
    local failed_tools=0
    
    # Disable errexit temporarily for arithmetic operations to prevent premature exit
    set +e
    
    # Prerequisites check
    log_info "Checking prerequisites..."
    command_exists python3 || error_exit "python3 is not installed"
    command_exists pipx || error_exit "pipx is not installed"
    log_success "Prerequisites check passed"
    
    # -------------------------------------------------------------------------
    # Mobile VAPT Tools
    # -------------------------------------------------------------------------
    log_info ""
    log_info "═══ Installing Mobile VAPT Tools ═══"
    
    # Install MobSF (if directory exists)
    if [[ -n "${TOOLS_MOBILE_VAPT:-}" ]] && [[ -d "${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF" ]]; then
        total_tools=$((total_tools + 1))
        log_info "Setting up MobSF..."
        
        if cd "${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF" 2>/dev/null; then
            if [[ -x setup.sh ]]; then
                chmod +x setup.sh
                log_info "Creating virtual environment..."
                python3 -m venv venv
                
                log_info "Installing MobSF..."
                if bash -c "source venv/bin/activate && ./setup.sh" 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✓ MobSF installed successfully"
                    successful_tools=$((successful_tools + 1))
                else
                    log_warn "✗ MobSF installation failed"
                    failed_tools=$((failed_tools + 1))
                fi
            else
                log_warn "MobSF setup.sh not found or not executable"
                failed_tools=$((failed_tools + 1))
            fi
            cd - >/dev/null || true
        else
            log_warn "Cannot access MobSF directory"
            failed_tools=$((failed_tools + 1))
        fi
    else
        log_info "MobSF directory not present, skipping (will be available after image copy)..."
    fi
    
    # -------------------------------------------------------------------------
    # Web VAPT Tools
    # -------------------------------------------------------------------------
    log_info ""
    log_info "═══ Installing Web VAPT Tools ═══"
    
    # Install Arjun
    total_tools=$((total_tools + 1))
    log_info "Installing Arjun..."
    if pipx install arjun 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "✓ Arjun installed"
        successful_tools=$((successful_tools + 1))
    else
        log_warn "✗ Arjun installation failed"
        failed_tools=$((failed_tools + 1))
    fi
    
    # Install HawkScan (if directory exists)
    if [[ -n "${TOOLS_WEB_VAPT:-}" ]] && [[ -d "${TOOLS_WEB_VAPT}/HawkScan" ]]; then
        total_tools=$((total_tools + 1))
        log_info "Installing HawkScan..."
        if cd "${TOOLS_WEB_VAPT}/HawkScan" 2>/dev/null; then
            if [[ -f setup.py ]]; then
                if python3 setup.py install 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✓ HawkScan installed"
                    successful_tools=$((successful_tools + 1))
                else
                    log_warn "✗ HawkScan installation failed"
                    failed_tools=$((failed_tools + 1))
                fi
            fi
            cd - >/dev/null || true
        else
            log_warn "Cannot access HawkScan directory"
            failed_tools=$((failed_tools + 1))
        fi
    else
        log_info "HawkScan not present, skipping..."
    fi
    
    # Install LinkFinder (if directory exists)
    if [[ -n "${TOOLS_WEB_VAPT:-}" ]] && [[ -d "${TOOLS_WEB_VAPT}/LinkFinder" ]]; then
        total_tools=$((total_tools + 1))
        log_info "Installing LinkFinder..."
        if cd "${TOOLS_WEB_VAPT}/LinkFinder" 2>/dev/null; then
            if [[ -f setup.py ]]; then
                if python3 setup.py install 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✓ LinkFinder installed"
                    successful_tools=$((successful_tools + 1))
                else
                    log_warn "✗ LinkFinder installation failed"
                    failed_tools=$((failed_tools + 1))
                fi
            fi
            cd - >/dev/null || true
        else
            log_warn "Cannot access LinkFinder directory"
            failed_tools=$((failed_tools + 1))
        fi
    else
        log_info "LinkFinder not present, skipping..."
    fi
    
    # Install Striker
    total_tools=$((total_tools + 1))
    if install_tool_with_pipx "${TOOLS_WEB_VAPT}/Striker" "requirements.txt"; then
        successful_tools=$((successful_tools + 1))
    else
        failed_tools=$((failed_tools + 1))
    fi
    
    # Install jwt_tool
    total_tools=$((total_tools + 1))
    if install_tool_with_pipx "${TOOLS_WEB_VAPT}/jwt_tool" "requirements.txt"; then
        successful_tools=$((successful_tools + 1))
    else
        failed_tools=$((failed_tools + 1))
    fi
    
    # Install Sublist3r (if directory exists)
    if [[ -n "${TOOLS_WEB_VAPT:-}" ]] && [[ -d "${TOOLS_WEB_VAPT}/Sublist3r" ]]; then
        total_tools=$((total_tools + 1))
        log_info "Installing Sublist3r..."
        if cd "${TOOLS_WEB_VAPT}/Sublist3r" 2>/dev/null; then
            if [[ -f setup.py ]]; then
                if python3 setup.py install 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✓ Sublist3r installed"
                    successful_tools=$((successful_tools + 1))
                else
                    log_warn "✗ Sublist3r installation failed"
                    failed_tools=$((failed_tools + 1))
                fi
            fi
            cd - >/dev/null || true
        else
            log_warn "Cannot access Sublist3r directory"
            failed_tools=$((failed_tools + 1))
        fi
    else
        log_info "Sublist3r not present, skipping..."
    fi
    
    # Install XSStrike
    total_tools=$((total_tools + 1))
    if install_tool_with_pipx "${TOOLS_WEB_VAPT}/XSStrike" "requirements.txt"; then
        successful_tools=$((successful_tools + 1))
    else
        failed_tools=$((failed_tools + 1))
    fi
    
    # Install Ghauri (if directory exists)
    if [[ -n "${TOOLS_WEB_VAPT:-}" ]] && [[ -d "${TOOLS_WEB_VAPT}/ghauri" ]]; then
        total_tools=$((total_tools + 1))
        log_info "Installing Ghauri..."
        if cd "${TOOLS_WEB_VAPT}/ghauri" 2>/dev/null; then
            if [[ -f setup.py ]]; then
                if python3 setup.py install 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✓ Ghauri installed"
                    successful_tools=$((successful_tools + 1))
                else
                    log_warn "✗ Ghauri installation failed"
                    failed_tools=$((failed_tools + 1))
                fi
            fi
            cd - >/dev/null || true
        else
            log_warn "Cannot access Ghauri directory"
            failed_tools=$((failed_tools + 1))
        fi
    else
        log_info "Ghauri not present, skipping..."
    fi
    
    # -------------------------------------------------------------------------
    # OSINT Tools
    # -------------------------------------------------------------------------
    log_info ""
    log_info "═══ Installing OSINT Tools ═══"
    
    # Install ReconSpider (if directory exists)
    if [[ -n "${TOOLS_OSINT:-}" ]] && [[ -d "${TOOLS_OSINT}/reconspider" ]]; then
        total_tools=$((total_tools + 1))
        log_info "Installing ReconSpider..."
        if cd "${TOOLS_OSINT}/reconspider" 2>/dev/null; then
            if [[ -f setup.py ]]; then
                # Fix urllib3 version
                sed -i 's/urllib3/urllib3==1.26.13/g' setup.py 2>/dev/null || true
                if python3 setup.py install 2>&1 | tee -a "${LOG_FILE}"; then
                    log_success "✓ ReconSpider installed"
                    successful_tools=$((successful_tools + 1))
                else
                    log_warn "✗ ReconSpider installation failed"
                    failed_tools=$((failed_tools + 1))
                fi
            fi
            cd - >/dev/null || true
        else
            log_warn "Cannot access ReconSpider directory"
            failed_tools=$((failed_tools + 1))
        fi
    else
        log_info "ReconSpider not present, skipping..."
    fi
    
    # Install Recon-ng
    total_tools=$((total_tools + 1))
    if install_tool_with_pipx "${TOOLS_OSINT}/recon-ng" "REQUIREMENTS"; then
        successful_tools=$((successful_tools + 1))
    else
        failed_tools=$((failed_tools + 1))
    fi
    
    # Install Metagoofil
    total_tools=$((total_tools + 1))
    if install_tool_with_pipx "${TOOLS_OSINT}/metagoofil" "requirements.txt"; then
        successful_tools=$((successful_tools + 1))
    else
        failed_tools=$((failed_tools + 1))
    fi
    
    # Install theHarvester
    total_tools=$((total_tools + 1))
    if install_tool_with_pipx "${TOOLS_OSINT}/theHarvester" "requirements/base.txt"; then
        successful_tools=$((successful_tools + 1))
    else
        failed_tools=$((failed_tools + 1))
    fi
    
    # -------------------------------------------------------------------------
    # Additional Tools from PyPI
    # -------------------------------------------------------------------------
    log_info ""
    log_info "═══ Installing Additional Security Tools ═══"
    
    local pypi_tools=(
        "objection"
        "octosuite"
        "dirsearch"
        "sqlmap"
        "frida-tools"
        "detect-secrets"
    )
    
    for tool in "${pypi_tools[@]}"; do
        total_tools=$((total_tools + 1))
        log_info "Installing ${tool}..."
        if pipx install "${tool}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "✓ ${tool} installed"
            successful_tools=$((successful_tools + 1))
        else
            log_warn "✗ ${tool} installation failed"
            failed_tools=$((failed_tools + 1))
        fi
    done
    
    # -------------------------------------------------------------------------
    # Final Configuration
    # -------------------------------------------------------------------------
    log_info ""
    log_info "Configuring environment..."
    
    # Add pipx binaries to PATH
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc
        log_success "Added pipx binaries to PATH"
    fi
    
    # -------------------------------------------------------------------------
    # Installation Summary
    # -------------------------------------------------------------------------
    log_info ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Installation Summary"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Total tools attempted: ${total_tools}"
    log_success "Successfully installed: ${successful_tools}"
    if [[ ${failed_tools} -gt 0 ]]; then
        log_warn "Failed installations: ${failed_tools}"
    fi
    
    # Calculate success rate (avoid division by zero)
    if [[ ${total_tools} -gt 0 ]]; then
        local success_rate=$((successful_tools * 100 / total_tools))
        log_info "Success rate: ${success_rate}%"
    else
        log_info "No tools attempted (directories may be populated after image copy)"
    fi
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Success if we either installed all attempted tools, or if no tools were attempted yet
    if [[ ${total_tools} -eq 0 ]]; then
        log_info "✓ Python module installer ready (tools will be installed after image assembly)"
        return 0
    elif [[ ${failed_tools} -eq 0 ]]; then
        log_success "✓ All Python tools installed successfully!"
        return 0
    else
        log_warn "Some tools failed to install. Check ${LOG_FILE} for details."
        # Don't fail the build if tools aren't present yet
        return 0
    fi
}

# Execute main function
main "$@"