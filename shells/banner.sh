#!/usr/bin/env bash

###############################################################################
# Nightingale Banner Script
# Description: Displays ASCII art banner and sets up networking aliases
# Author: Raja Nagori
# Email: raja.nagori@owasp.org
# License: GPL-3.0
###############################################################################

# Enable strict error handling only for non-interactive shells
# Interactive shells should not exit on non-zero statuses (which breaks ttyd)
case $- in
    *i*)
        # Interactive: keep safer pipes but do not use -e or -u
        set -o pipefail
        ;;
    *)
        # Non-interactive scripts: use strict mode
        set -euo pipefail
        ;;
esac

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

# Fix output buffering issues for ttyd terminal
# These settings prevent freezing after command execution
export PYTHONUNBUFFERED=1
export PYTHONIOENCODING=utf-8
export STDBUF=1
# Ensure unbuffered output for interactive shells
if [ -t 1 ]; then
    export TERM=xterm-256color
    # Disable line buffering
    stty -ixon -ixoff 2>/dev/null || true
fi

# Define help function
help() { 
    command "$@" --help 2>/dev/null | less -R -X -F -K || command "$@"
}

# Set up additional aliases
alias h="help"