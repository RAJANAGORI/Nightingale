#!/bin/bash

# Function to install a tool using pipx and a requirements file
install_tool_with_pipx() {
    local tool_dir=$1
    local requirements_file=$2
    echo "Installing $(basename $tool_dir)..."
    cd "$tool_dir"
    while read -r p; do pipx install "$p"; done < "$requirements_file"
    echo "$(basename $tool_dir) installation completed."
}

# Create and activate MobSF virtual environment
echo "Setting up MobSF..."
cd "${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF"
chmod +x setup.sh
echo "Creating virtual environment..."
python3 -m venv venv
echo "Activating virtual environment..."
source venv/bin/activate

# Install MobSF
echo "Installing MobSF..."
./setup.sh
echo "MobSF installation completed."

# Exit the virtual environment
echo "Exiting virtual environment..."
deactivate

# Install Arjun
echo "Installing Arjun..."
cd "${TOOLS_WEB_VAPT}/Arjun"
pipx install arjun
echo "Arjun installation completed."

# Install HawkScan
echo "Installing HawkScan..."
cd "${TOOLS_WEB_VAPT}/HawkScan"
python3 setup.py install
echo "HawkScan installation completed."

# Install LinkFinder
echo "Installing LinkFinder..."
cd "${TOOLS_WEB_VAPT}/LinkFinder"
python3 setup.py install
echo "LinkFinder installation completed."

# Install Striker
install_tool_with_pipx "${TOOLS_WEB_VAPT}/Striker" "requirements.txt"

# Install jwt_tool
install_tool_with_pipx "${TOOLS_WEB_VAPT}/jwt_tool" "requirements.txt"

# Install Sublist3r
echo "Installing Sublist3r..."
cd "${TOOLS_WEB_VAPT}/Sublist3r"
python3 setup.py install
echo "Sublist3r installation completed."

# Install XSStrike
install_tool_with_pipx "${TOOLS_WEB_VAPT}/XSStrike" "requirements.txt"

# Install ReconSpider
echo "Installing ReconSpider..."
cd "${TOOLS_OSINT}/reconspider"
sed -i 's/urllib3/urllib3==1.26.13/g' setup.py
python3 setup.py install
echo "ReconSpider installation completed."

# Install Recon-ng
cd "${TOOLS_OSINT}/recon-ng"
install_tool_with_pipx "${TOOLS_OSINT}/recon-ng" "REQUIREMENTS"

# Install Metagoofil
install_tool_with_pipx "${TOOLS_OSINT}/metagoofil" "requirements.txt"

# Install theHarvester
install_tool_with_pipx "${TOOLS_OSINT}/theHarvester" "requirements/base.txt"

# Install Ghauri
cd "${TOOLS_WEB_VAPT}/ghauri"
# install_tool_with_pipx  "--include-deps ${TOOLS_WEB_VAPT}/ghauri" "requirements.txt"
# pip3 install -r requirements.txt
python3 setup.py install


# Install objection, octosuite, dirsearch, sqlmap, and frida-tools from PyPI
echo "Installing objection, octosuite, dirsearch, sqlmap, and frida-tools..."
pipx install objection
pipx install octosuite
pipx install dirsearch
pipx install sqlmap
pipx install frida-tools
pipx install detect-secrets
echo "objection, octosuite, dirsearch, sqlmap, detect-secrets, and frida-tools installation completed."

# Add pipx binaries to PATH
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc

echo "All tools installed successfully!"