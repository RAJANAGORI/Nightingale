#!/bin/bash

# Define the list of available tools and their respective check commands
declare -A TOOLS=(
    ["zsh"]="zsh --version"
    ["metasploit"]="msfconsole --version"
    ["python_mobsf"]="[ -d ${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF/venv ]"
    ["python_arjun"]="pipx list | grep arjun"
    ["python_hawkscan"]="pip list | grep HawkScan"
    ["python_linkfinder"]="pip list | grep LinkFinder"
    ["python_striker"]="pipx list | grep striker"
    ["python_jwt_tool"]="pipx list | grep jwt_tool"
    ["python_sublist3r"]="pip list | grep Sublist3r"
    ["python_xsstrike"]="pipx list | grep XSStrike"
    ["python_spiderfoot"]="pipx list | grep spiderfoot"
    ["python_reconspider"]="pip list | grep reconspider"
    ["python_recon_ng"]="pipx list | grep recon-ng"
    ["python_metagoofil"]="pipx list | grep metagoofil"
    ["python_theharvester"]="pipx list | grep theHarvester"
    ["python_objection"]="pipx list | grep objection"
    ["python_octosuite"]="pipx list | grep octosuite"
    ["python_dirsearch"]="pipx list | grep dirsearch"
    ["python_sqlmap"]="pipx list | grep sqlmap"
    ["python_frida_tools"]="pipx list | grep frida-tools"
    ["go_amass"]="go list -m github.com/owasp-amass/amass/v3 | grep amass"
    ["go_assetfinder"]="go list -m github.com/tomnomnom/assetfinder | grep assetfinder"
    ["go_ffuf"]="go list -m github.com/ffuf/ffuf | grep ffuf"
    ["go_gau"]="go list -m github.com/lc/gau/v2 | grep gau"
    ["go_gf"]="go list -m github.com/tomnomnom/gf | grep gf"
    ["go_gobuster"]="go list -m github.com/OJ/gobuster/v3 | grep gobuster"
    ["go_httprobe"]="go list -m github.com/tomnomnom/httprobe | grep httprobe"
    ["go_httpx"]="go list -m github.com/projectdiscovery/httpx | grep httpx"
    ["go_nuclei"]="go list -m github.com/projectdiscovery/nuclei/v3 | grep nuclei"
    ["go_qsreplace"]="go list -m github.com/tomnomnom/qsreplace | grep qsreplace"
    ["go_subfinder"]="go list -m github.com/projectdiscovery/subfinder/v2 | grep subfinder"
    ["go_waybackurls"]="go list -m github.com/tomnomnom/waybackurls | grep waybackurls"
)

# Function to check if a tool is already installed
is_installed() {
    local check_command=$1
    if eval "$check_command" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to activate zsh
activate_zsh() {
    echo "Activating Zsh..."
    sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions > /dev/null 2>&1 &&\
    dos2unix ${HOME}/.zshrc > /dev/null 2>&1 &&\
    cat /temp/banner.sh >> ${HOME}/.zshrc
}

# Function to activate metasploit
activate_metasploit() {
    echo "Activating Metasploit..."
    curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor | tee /usr/share/keyrings/metasploit.gpg > /dev/null &&\
    echo "deb [signed-by=/usr/share/keyrings/metasploit.gpg] https://apt.metasploit.com/ buster main" | tee /etc/apt/sources.list.d/metasploit.list > /dev/null &&\
    apt update > /dev/null 2>&1 &&\
    apt install -y metasploit-framework > /dev/null 2>&1
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

# Function to display help information
display_help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  zsh        Activate Zsh"
    echo "  metasploit Activate Metasploit"
    echo "  python     Activate Python modules"
    echo "  go         Activate Go modules"
    echo "  --help     Display this help message"
    echo "  --list     List available tools"
}

# Function to list available tools
list_tools() {
    echo "Available tools:"
    echo "  zsh"
    echo "  metasploit"
    echo "  python tools:"
    echo "    - mobsf"
    echo "    - arjun"
    echo "    - hawkscan"
    echo "    - linkfinder"
    echo "    - striker"
    echo "    - jwt_tool"
    echo "    - sublist3r"
    echo "    - xsstrike"
    echo "    - spiderfoot"
    echo "    - reconspider"
    echo "    - recon-ng"
    echo "    - metagoofil"
    echo "    - theharvester"
    echo "    - objection"
    echo "    - octosuite"
    echo "    - dirsearch"
    echo "    - sqlmap"
    echo "    - frida-tools"
    echo "  go tools:"
    echo "    - amass"
    echo "    - assetfinder"
    echo "    - ffuf"
    echo "    - gau"
    echo "    - gf"
    echo "    - gobuster"
    echo "    - httprobe"
    echo "    - httpx"
    echo "    - nuclei"
    echo "    - qsreplace"
    echo "    - subfinder"
    echo "    - waybackurls"
}

# Main script logic
case "$1" in
    zsh)
        if is_installed "${TOOLS["zsh"]}"; then
            echo "Zsh is already installed."
        else
            activate_zsh
        fi
        ;;
    metasploit)
        if is_installed "${TOOLS["metasploit"]}"; then
            echo "Metasploit is already installed."
        else
            activate_metasploit
        fi
        ;;
    python)
        activate_python
        ;;
    go)
        activate_go
        ;;
    --help)
        display_help
        ;;
    --list)
        list_tools
        ;;
    *)
        echo "Invalid option. Use --help for usage information."
        exit 1
        ;;
esac