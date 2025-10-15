#!/bin/bash

# Terminal wrapper script to handle large outputs gracefully
# This prevents ttyd buffer overflow issues

# Function to handle large command outputs
handle_large_output() {
    local cmd="$1"
    
    # Check if command typically produces large output
    if [[ "$cmd" =~ (nmap|help|--help|-h|man|cat|less|more|tail|head|find|grep) ]]; then
        # Use pager for large outputs
        eval "$cmd" | less -R -X -F
    else
        # Execute normally
        eval "$cmd"
    fi
}

# Enhanced prompt with buffer status
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Welcome message
echo "🚀 Nightingale Terminal - Optimized for large outputs"
echo "💡 Tip: Large outputs will use pager automatically"
echo ""

# Main shell loop
while true; do
    # Read command with timeout
    read -t 3600 -r -p "$PS1" cmd
    
    # Handle empty commands
    if [[ -z "$cmd" ]]; then
        continue
    fi
    
    # Handle exit commands
    if [[ "$cmd" =~ ^(exit|quit|logout)$ ]]; then
        echo "Goodbye! 👋"
        exit 0
    fi
    
    # Execute command with large output handling
    handle_large_output "$cmd"
done
