#!/bin/bash 
# Install Impacket
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
sed -i 's/^python-whois$/python-whois==0.7.3/' requirements.txt
python3 -m pip install -r requirements.txt

# Install LinkFinder
cd "${TOOLS_WEB_VAPT}/LinkFinder"
# python3 setup.py install
python3 -m pip install jsbeautifier

# Install Striker
cd "${TOOLS_WEB_VAPT}/Striker"
pip3 install -r requirements.txt

# Install dirsearch
cd "${TOOLS_WEB_VAPT}/dirsearch"
# python3 setup.py install
python3 -m pip install \
    PySocks>=1.7.1 \
    Jinja2>=3.0.0 \
    certifi>=2017.4.17 \
    urllib3>=1.21.1 \
    cryptography>=2.8 \
    cffi>=1.14.0 \
    defusedxml>=0.7.0 \
    markupsafe>=2.0.0 \
    pyopenssl>=21.0.0 \
    idna>=2.5 \
    chardet>=3.0.2 \
    charset_normalizer~=2.0.0 \
    requests>=2.27.0 \
    requests_ntlm>=1.1.0 \
    colorama>=0.4.4 \
    ntlm_auth>=1.5.0 \
    pyparsing>=2.4.7 \
    beautifulsoup4>=4.8.0 \
    mysql-connector-python>=8.0.20 \
    psycopg[binary]>=3.0


# Install jwt_tool
cd "${TOOLS_WEB_VAPT}/jwt_tool"
pip3 install -r requirements.txt

# Install Sublist3r
cd "${TOOLS_WEB_VAPT}/Sublist3r"
# python3 setup.py install
python3 -m pip install \
    argparse \
    dnspython \
    requests

# Install XSStrike
cd "${TOOLS_WEB_VAPT}/XSStrike"
pip3 install -r requirements.txt

# Install WhatWeb
cd "${TOOLS_WEB_VAPT}/WhatWeb"
make install && bundle install

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
pip3 install objection octosuite \
            sqlmap