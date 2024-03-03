#!/bin/bash

# # Install Impacket
# cd "${TOOLS_RED_TEAMING}/impacket"
# python3 setup.py build && python3 setup.py install

echo "Installing Impacket..."
# Add echo statements to indicate the progress
cd "${TOOLS_RED_TEAMING}/impacket"
echo "Building Impacket..."
python3 setup.py build && python3 setup.py install
echo "Impacket installation completed."

# Create and activate MobSF virtual environment, and install MobSF
echo "Setting up MobSF..."
cd "${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF"
echo "Creating virtual environment..."
python3 -m venv venv
echo "Installing MobSF..."
bash setup.sh
echo "MobSF installation completed."

# Install Arjun
echo "Installing Arjun..."
cd "${TOOLS_WEB_VAPT}/Arjun"
python3 setup.py install 
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
echo "Installing Striker..."
cd "${TOOLS_WEB_VAPT}/Striker"
# pipx install -r requirements.txt
while read p; do pipx install "$p"; done < requirements.txt
echo "Striker installation completed."

# Install jwt_tool
echo "Installing jwt_tool..."
cd "${TOOLS_WEB_VAPT}/jwt_tool"
pipx install -r requirements.txt --break-system-packages
# while read p; do pipx install "$p"; done < requirements.txt
echo "jwt_tool installation completed."

# Install Sublist3r
echo "Installing Sublist3r..."
cd "${TOOLS_WEB_VAPT}/Sublist3r"
python3 setup.py install 
echo "Sublist3r installation completed."

# Install XSStrike
echo "Installing XSStrike..."
cd "${TOOLS_WEB_VAPT}/XSStrike"
# pipx install -r requirements.txt 
while read p; do pipx install "$p"; done < requirements.txt
echo "XSStrike installation completed."

# Install SpiderFoot
echo "Installing SpiderFoot..."
cd "${TOOLS_OSINT}/spiderfoot"
# pipx install -r requirements.txt 
while read p; do pipx install "$p"; done < requirements.txt
echo "SpiderFoot installation completed."

# Install ReconSpider
echo "Installing ReconSpider..."
cd "${TOOLS_OSINT}/reconspider"
sed -i 's/urllib3/urllib3==1.26.13/g' setup.py
python3 setup.py install
echo "ReconSpider installation completed."

# Install Recon-ng
echo "Installing Recon-ng..."
cd "${TOOLS_OSINT}/recon-ng"
# pipx install -r REQUIREMENTS
while read p; do pipx install "$p"; done < REQUIREMENTS
echo "Recon-ng installation completed."

# Install Metagoofil
echo "Installing Metagoofil..."
cd "${TOOLS_OSINT}/metagoofil"
# pipx install -r requirements.txt
while read p; do pipx install "$p"; done < requirements.txt
echo "Metagoofil installation completed."

# Install theHarvester
echo "Installing theHarvester..."
cd "${TOOLS_OSINT}/theHarvester"
# pipx install -r requirements/base.txt
while read p; do pipx install "$p"; done < requirements/base.txt
echo "theHarvester installation completed."

# Install objection and octosuite from PyPI
echo "Installing objection and octosuite..."
pipx install objection 
pipx install octosuite 
pipx install dirsearch 
pipx install sqlmap
echo "Objection, octosuite, dirsearch, and sqlmap installation completed."