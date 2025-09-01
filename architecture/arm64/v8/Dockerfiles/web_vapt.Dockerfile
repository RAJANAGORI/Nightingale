## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:arm64
## Installing tools using apt-get for web vapt
RUN \
    apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    unzip \
    whatweb \
    curl \
    wget \
    pipx \
    hashcat \
    hashcat-data && \
### Creating Directories
    cd /home && \
    mkdir -p tools_web_vapt .gf 

### Creating Directories
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt/
ENV GREP_PATTERNS=/home/.gf/

WORKDIR ${GREP_PATTERNS}

RUN \
    git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git ${GREP_PATTERNS}

WORKDIR ${TOOLS_WEB_VAPT}
# git clonning of tools repository
RUN \
    #git clone of xsstrike
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git &&\
    #git clone arjun
    git clone --depth 1  https://github.com/s0md3v/Arjun.git && \
    # git clone massdns
    git clone --depth 1 https://github.com/blechschmidt/massdns.git && \
    # git clone strike
    git clone --depth 1 https://github.com/s0md3v/Striker.git && \
    # git clone LinkFinder
    git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git &&  \
    #git clone sublister
    git clone --depth 1 https://github.com/aboul3la/Sublist3r.git &&\
    #git clone jwt_tool
    git clone --depth 1 https://github.com/ticarpi/jwt_tool.git &&\
    #git clone whatweb
    git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git &&\
    #Install git leaks
    git clone --depth 1 https://github.com/gitleaks/gitleaks.git &&\
    # Install Ghauri
    git clone --depth 1 https://github.com/r0oth3x49/ghauri.git

### Installing Tools 
RUN \
## Installing Arjun
    cd Arjun && \
    pipx install arjun && \
    cd ..

RUN \
## Installing LinkFinderd
    cd LinkFinder && \
    while read p; do pipx install "$p"; done < requirements.txt &&\
    cd ..
    
RUN \
## Installing Striker
    cd Striker && \
    while read p; do pipx install -f --include-deps "$p"; done < requirements.txt &&\
    cd ..

RUN \
##  INstalling dirsearch
    pipx install dirsearch

RUN \
## installin jwt_tool
    cd jwt_tool && \
    pip3 install -r requirements.txt --break-system-packages &&\
    cd ..

RUN \
## INstalling Sublist3r
    cd Sublist3r && \
    pipx install Sublist3r &&\
    cd ..

RUN \
## INstall XSStrike
    cd XSStrike && \
    while read p; do pipx install "$p"; done < requirements.txt &&\
    cd ..

RUN \
### Installing Trufflehog
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin


RUN \
## Installing Git leaks
    cd gitleaks &&\
    make build

RUN \
    cd ghauri && \
    while read p; do pipx install --include-deps "$p"; done < requirements.txt && \
    python3 setup.py install

RUN \
### Installing Amass 
    wget --quiet https://github.com/owasp-amass/amass/releases/download/v5.0.0/amass_Linux_arm64.zip -O amass.zip &&\
    unzip amass.zip && \
    mv amass_Linux_arm64/amass /usr/local/bin && rm -rf amass_Linux_arm64 amass.zip && \
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc
    
WORKDIR /home