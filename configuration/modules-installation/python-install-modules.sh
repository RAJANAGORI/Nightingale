#/bin/bash
cd ${TOOLS_RED_TEAMING}/impacket
python3 setup.py build
python3 setup.py install

cd ${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF
python3 -m venv venv 
bash setup.sh

cd ${TOOLS_WEB_VAPT}/Arjun
python3 setup.py install 

cd ${TOOLS_WEB_VAPT}/HawkScan
python3 setup.py install 

cd ${TOOLS_WEB_VAPT}/LinkFinder 
python3 setup.py install

cd ${TOOLS_WEB_VAPT}/Striker 
pip3 install -r requirements.txt

cd ${TOOLS_WEB_VAPT}/dirsearch
python3 setup.py install 

cd ${TOOLS_WEB_VAPT}/jwt_tool
pip3 install -r requirements.txt

cd ${TOOLS_WEB_VAPT}/Sublist3r
python3 setup.py install

cd ${TOOLS_WEB_VAPT}/XSStrike
pip3 install -r requirements.txt

cd ${TOOLS_WEB_VAPT}/spiderfoot 
pip3 install -r requirements.txt

cd ${TOOLS_WEB_VAPT}/WhatWeb 
make install

cd ${TOOLS_OSINT}/reconspider
sed -i 's/urllib3/urllib3==1.26.13/g' setup.py
python3 setup.py install

cd ${TOOLS_OSINT}/recon-ng 
pip3 install -r REQUIREMENTS

# Installation from pypi
pip3 install objection octosuite

cd ${TOOLS_OSINT}/metagoofil
pip3 install -r requirements.txt

cd ${TOOLS_OSINT}/theHarvester
python3 -m pip3 install -r requirements/base.txt