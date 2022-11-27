
python3 ${TOOLS_RED_TEAMING}/impacket/setup.py build && ${TOOLS_RED_TEAMING}/impacket/python3 setup.py install

python3 -m venv ${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF/venv && bash ${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF/setup.sh

python3 ${TOOLS_WEB_VAPT}/Arjun/setup.py install

python3 ${TOOLS_WEB_VAPT}/HawkScan/setup.py install

python3 ${TOOLS_WEB_VAPT}/LinkFinder/setup.py install

pip install -r ${TOOLS_WEB_VAPT}/Striker/requirements.txt

python3 ${TOOLS_WEB_VAPT}/dirsearch/setup.py install

pip install -r ${TOOLS_WEB_VAPT}/jwt_tool/requirements.txt

python3 ${TOOLS_WEB_VAPT}/Sublist3r/setup.py install

pip install -r ${TOOLS_WEB_VAPT}/XSStrike/requirements.txt

${TOOLS_WEB_VAPT}/WhatWeb/make install

pip install -r ${TOOLS_OSINT}/spiderfoot/requirements.txt

sed -i 's/urllib3/urllib3==1.26.13/g' ${TOOLS_OSINT}/reconspider/setup.py && python3 ${TOOLS_OSINT}/reconspider/setup.py install

pip install -r ${TOOLS_OSINT}/recon-ng/REQUIREMENTS

pip install -r ${TOOLS_OSINT}/metagoofil/requirements.txt

pip install -r ${TOOLS_OSINT}/theHarvester/requirements/base.txt

# Installation from pypi
pip install objection octosuite