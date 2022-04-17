## Taking Image from Docker Hub for Programming language support
FROM rajanagori/nightingale_programming_image:v1 

## Installing tools using apt-get for web vapt
RUN \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    make \
    cmake \
    bundler \
    dirb 

### Creating Directories
RUN \
    cd /home && \
    mkdir -p tools_web_vapt .gf binaries

### Creating Directories
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt/
ENV GREP_PATTERNS=/home/.gf/
ENV BINARIES=/home/binaries/

WORKDIR ${GREP_PATTERNS}

RUN \
    git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git ${GREP_PATTERNS}

WORKDIR ${TOOLS_WEB_VAPT}
# git clonning of tools repository
RUN \
    # Git clone of SqlMap
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git &&\
    # Git clone of HawkScan
    git clone --depth 1 https://github.com/c0dejump/HawkScan.git &&\
    #git clone of xsstrike
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git &&\
    #git clone whatweb
    git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git && \
    #git clone dirsearch
    git clone --depth 1  https://github.com/maurosoria/dirsearch.git && \
    #git clone arjun
    git clone --depth 1  https://github.com/s0md3v/Arjun.git && \
    # git clone massdns
    git clone --depth 1 https://github.com/blechschmidt/massdns.git && \
    # git clone strike
    git clone --depth 1 https://github.com/s0md3v/Striker.git && \
    # git clone LinkFinder
    git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git &&  \
    #git clone Spiderfoot
    git clone --depth 1 https://github.com/smicallef/spiderfoot.git && \
    #git clone sublister
    git clone --depth 1 https://github.com/aboul3la/Sublist3r.git &&\
    #git clone jwt_tool
    git clone --depth 1 https://github.com/ticarpi/jwt_tool.git

### Installing Tools 

RUN \
## Installing Arjun
    cd Arjun && \
    python3 setup.py install && \
    cd .. && \

## Installing HawkScan
    cd HawkScan && \
    python3 setup.py install && \
    cd .. && \

## Installing LinkFinderd
    cd LinkFinder && \
    python3 setup.py install &&\
    cd .. && \

## Installing Striker
    cd Striker && \
    pip3 install -r requirements.txt &&\
    cd .. && \

## Installating Whatweb
    cd WhatWeb && \
    make && \
    chmod +x whatweb && mv whatweb /usr/local/bin/ && \
    rm -rf WhatWeb && \
    cd .. && \

##  INstalling dirsearch
    cd dirsearch && \
    python3 setup.py install && \
    cd .. && \

## installin jwt_tool
    cd jwt_tool && \
    pip3 install -r requirements.txt &&\
    cd .. && \

## INstalling Sublist3r
    cd Sublist3r && \
    python3 setup.py install &&\
    cd .. && \

## INstall XSStrike
    cd XSStrike && \
    pip3 install -r requirements.txt &&\
    cd .. && \

## INstall Spiderfoot
    cd spiderfoot && \
    pip3 install -r requirements.txt &&\
    cd .. && \

### Installing Amass 
    wget --quiet https://github.com/OWASP/Amass/releases/download/v3.16.0/amass_linux_amd64.zip -O amass.zip &&\
    unzip amass.zip && \
    mv amass_linux_amd64/amass /usr/local/bin && rm -rf amass_linux_amd64 amass.zip

## All binaries will store here
WORKDIR ${BINARIES}
## INstallation stuff
COPY \
    binary/ ${BINARIES}

RUN \
    ln -s ${BINARIES}/assetfinder /usr/local/bin/ && \
    ln -s ${BINARIES}/gau /usr/local/bin/ && \
    ln -s ${BINARIES}/gf /usr/local/bin/ && \
    ln -s ${BINARIES}/httprobe /usr/local/bin/ && \
    ln -s ${BINARIES}/httpx /usr/local/bin/ && \
    ln -s ${BINARIES}/jadx /usr/local/bin/ && \
    ln -s ${BINARIES}/nuclei /usr/local/bin/ && \
    ln -s ${BINARIES}/qsreplace /usr/local/bin/ && \
    ln -s ${BINARIES}/subfinder /usr/local/bin/ && \
    ln -s ${BINARIES}/waybackurls /usr/local/bin/ && \
    ln -s ${BINARIES}/fuff /usr/local/bin/ && \
    ln -s ${BINARIES}/findomain /usr/local/bin/ && \
    ln -s ${BINARIES}/gobuster /usr/local/bin/ && \
    ln -s ${BINARIES}/xray /usr/local/bin/ && \
    wget -L https://github.com/RAJANAGORI/Nightingale/blob/main/binary/ttyd?raw=true -O ttyd && \
    chmod +x *

WORKDIR /home

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*








