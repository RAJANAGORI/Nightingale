#!/bin/bash

# Function to check if a tool is already installed
is_installed() {
    local check_command=$1
    if eval "$check_command" &> /dev/null; then
        return 0
    else
        return 1
    fi
}
# Function to activate python
activate_python() {
    echo "Activating Python modules..."
    echo "Please wait till the Process completed..."
    dos2unix ${SHELLS}/python-install-modules.sh > /dev/null 2>&1 && chmod +x ${SHELLS}/python-install-modules.sh && ${SHELLS}/python-install-modules.sh > /dev/null 2>&1
    pv -t ${SHELLS}/python-install-modules.sh | bash > /dev/null 2>&1
    echo "Python modules activation completed."
}

# Function to activate go
activate_go() {
    echo "Activating Go modules..."
    echo "Please wait till the Process completed..."
    dos2unix ${SHELLS}/go-install-modules.sh > /dev/null 2>&1 && chmod +x ${SHELLS}/go-install-modules.sh && ${SHELLS}/go-install-modules.sh > /dev/null 2>&1
    pv -t ${SHELLS}/go-install-modules.sh | bash > /dev/null 2>&1
    echo "Go modules activation completed."
}


# Main script logic
case "$1" in
    python)
        activate_python
        ;;
    go)
        activate_go
        ;;
    --list)
        list_tools
        ;;
    *)
        echo "Invalid option. Use --help for usage information."
        exit 1
        ;;
esac