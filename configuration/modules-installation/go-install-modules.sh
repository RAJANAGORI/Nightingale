#!/bin/bash

# Function to install a Go tool
install_go_tool() {
    tool=$1
    echo "Installing $tool..."
    go install "$tool"
}

# List of tools to install
tools=(
    "github.com/owasp-amass/amass/v3/...@latest"
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/ffuf/ffuf@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/tomnomnom/gf@latest"
    "github.com/OJ/gobuster/v3@latest"
    "github.com/tomnomnom/httprobe@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    "github.com/tomnomnom/qsreplace@latest"
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    "github.com/projectdiscovery/katana/cmd/katana@latest"
    "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
)

# Loop through the tools and install each one
for tool in "${tools[@]}"; do
    install_go_tool "$tool"
done

echo "All tools installed successfully!"