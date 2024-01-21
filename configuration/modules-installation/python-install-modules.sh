#!/bin/bash

# # Install Impacket
# cd "${TOOLS_RED_TEAMING}/impacket"
# python3 setup.py build && python3 setup.py install

# Create and activate MobSF virtual environment, and install MobSF
cd "${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF"
python3 -m venv venv
bash setup.sh

# Install Arjun
cd "${TOOLS_WEB_VAPT}/Arjun"
python3 setup.py install 

# Install HawkScan
cd "${TOOLS_WEB_VAPT}/HawkScan"
python3 setup.py install 

# Install LinkFinder
cd "${TOOLS_WEB_VAPT}/LinkFinder"
python3 setup.py install 

# Install Striker
cd "${TOOLS_WEB_VAPT}/Striker"
# pipx install -r requirements.txt
while read p; do pipx install "$p"; done < requirements.txt

# # Install dirsearch
# cd "${TOOLS_WEB_VAPT}/dirsearch"

# Install jwt_tool
cd "${TOOLS_WEB_VAPT}/jwt_tool"
# pipx install -r requirements.txt 
while read p; do pipx install "$p"; done < requirements.txt

# Install Sublist3r
cd "${TOOLS_WEB_VAPT}/Sublist3r"
python3 setup.py install 

# Install XSStrike
cd "${TOOLS_WEB_VAPT}/XSStrike"
# pipx install -r requirements.txt 
while read p; do pipx install "$p"; done < requirements.txt

# # Install WhatWeb
# cd "${TOOLS_WEB_VAPT}/WhatWeb"
# make install && bundle install

# Install SpiderFoot
cd "${TOOLS_OSINT}/spiderfoot"
# pipx install -r requirements.txt 
while read p; do pipx install "$p"; done < requirements.txt

# Install ReconSpider
cd "${TOOLS_OSINT}/reconspider"
sed -i 's/urllib3/urllib3==1.26.13/g' setup.py
python3 setup.py install

# Install Recon-ng
cd "${TOOLS_OSINT}/recon-ng"
# pipx install -r REQUIREMENTS
while read p; do pipx install "$p"; done < REQUIREMENTS

# Install Metagoofil
cd "${TOOLS_OSINT}/metagoofil"
# pipx install -r requirements.txt
while read p; do pipx install "$p"; done < requirements.txt

# Install theHarvester
cd "${TOOLS_OSINT}/theHarvester"
# pipx install -r requirements/base.txt
while read p; do pipx install "$p"; done < requirements/base.txt

# Install objection and octosuite from PyPI
pip install objection octosuite dirsearch sqlmap