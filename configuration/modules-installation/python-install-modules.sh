#!/bin/bash

# Install Impacket
cd "${TOOLS_RED_TEAMING}/impacket"
python3 setup.py build && python3 setup.py install

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
pip3 install -r requirements.txt

# # Install dirsearch
# cd "${TOOLS_WEB_VAPT}/dirsearch"

# Install jwt_tool
cd "${TOOLS_WEB_VAPT}/jwt_tool"
pip3 install -r requirements.txt

# Install Sublist3r
cd "${TOOLS_WEB_VAPT}/Sublist3r"
python3 setup.py install

# Install XSStrike
cd "${TOOLS_WEB_VAPT}/XSStrike"
pip3 install -r requirements.txt

# # Install WhatWeb
# cd "${TOOLS_WEB_VAPT}/WhatWeb"
# make install && bundle install

# Install SpiderFoot
cd "${TOOLS_OSINT}/spiderfoot"
pip3 install -r requirements.txt

# Install ReconSpider
cd "${TOOLS_OSINT}/reconspider"
sed -i 's/urllib3/urllib3==1.26.13/g' setup.py
python3 setup.py install

# Install Recon-ng
cd "${TOOLS_OSINT}/recon-ng"
pip3 install -r REQUIREMENTS

# Install Metagoofil
cd "${TOOLS_OSINT}/metagoofil"
pip3 install -r requirements.txt

# Install theHarvester
cd "${TOOLS_OSINT}/theHarvester"
pip3 install -r requirements/base.txt

# Install objection and octosuite from PyPI
pip3 install objection octosuite dirsearch sqlmap

#Installating Nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest