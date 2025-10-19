#!/usr/bin/env bash

###############################################################################
# Nightingale Banner Script
# Description: Displays ASCII art banner and sets up networking aliases
# Author: Raja Nagori
# Email: raja.nagori@owasp.org
# License: GPL-3.0
###############################################################################

# Enable strict error handling
set -euo pipefail

# Set secure PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

###############################################################################
# Main Functions
###############################################################################

# Display the Nightingale banner
display_banner() {
    if command -v figlet >/dev/null 2>&1; then
        figlet "Nightingale" 2>/dev/null || echo "=== NIGHTINGALE ===" 
        echo ""
        figlet -f term "Made by Raja Nagori <3 from India" 2>/dev/null || \
            echo "Made by Raja Nagori <3 from India"
    else
        echo "========================================="
        echo "           NIGHTINGALE"
        echo "   Docker for Pentesters"
        echo "   Made by Raja Nagori <3 from India"
        echo "========================================="
    fi
    echo ""
}

# Set up networking aliases for better clarity
setup_aliases() {
    # Force IPv4 for ping (explicitly)
    if command -v ping >/dev/null 2>&1; then
        alias ping="ping -4" 2>/dev/null || true
    fi
    
    # Explicit IPv6 ping
    if command -v ping6 >/dev/null 2>&1; then
        alias ping6="ping -6" 2>/dev/null || true
    fi
    
    # Additional useful aliases
    alias ll="ls -lah" 2>/dev/null || true
    alias la="ls -A" 2>/dev/null || true
    alias l="ls -CF" 2>/dev/null || true
}

###############################################################################
# Main Execution
###############################################################################

main() {
    display_banner
    setup_aliases
}

# Execute main function
main

# Set up environment variables
export GOTTY_URL=https://nightingale.local
export GOTTY_KEY=/root/.gotty.key
export GOTTY_CERT=/root/.gotty.crt
export PATH="$PATH:/root/.local/bin"
export PAGER="less -R -X -F -K"

# Define help function
help() { 
    command "$@" --help 2>/dev/null | less -R -X -F -K || command "$@"
}

# Set up additional aliases
alias h="help"