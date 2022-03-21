# Pulling the base image
FROM debian:latest

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"

## Banner shell and run shell file ##
COPY \
    shells/banner.sh /tmp/banner.sh
RUN \
    cat /tmp/banner.sh >> /root/.bashrc

USER root

#### Installing os tools and other dependencies.
RUN \
    # apt-get -y dist-upgrade && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -f install -y --no-install-recommends \
    #### Operating system dependecies start
    software-properties-common \
    ca-certificates \
    aapt \
    android-framework-res \
    autoconf \
    build-essential \
    dialog apt-utils \
    libantlr3-runtime-java \
    libcurl4-openssl-dev \
    libcurl4-openssl-dev \
    libguava-java \
    libiconv-hook1 \
    libiconv-hook-dev \
    libjson-c-dev \
    liblzma-dev \
    libpcap-dev \
    libpq-dev \
    libsmali-java \
    libsqlite3-dev \
    libssl-dev \
    libstringtemplate-java \
    libwebsockets-dev \
    libwww-perl \
    libxmlunit-java \
    libxpp3-java \
    libyaml-snake-java \
    libz-dev \
    postgresql \
    postgresql-client \
    postgresql-contrib \
    python3-venv \
    zlib1g-dev \

    ### Operating System Tools start here 
    htop \
    locate \
    snapd \
    tree \
    zsh \
    vim \
    ### Compression Techniques starts
    unzip \
    p7zip-full \
    ftp \
    dos2unix\
    ssh \
    ### Dev Essentials start here
    git \
    ruby \
    ruby-dev \
    bundler \
    bison \
    flex \
    autoconf \
    automake \
    ruby-full \
    make \
    cmake \
    curl \
    gnupg \
    patch \
    ruby-bundler \
    nasm \
    wget 

RUN \
    gem install nokogiri 

### Programming Language Support
RUN \
    apt-get install -y \
    python3-pip \
    python3-dev &&\
    cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    python -m pip install --upgrade pip

RUN \
    apt-get install -y --no-install-recommends \
    default-jre-headless \
    default-jdk-headless

# Install go and node
WORKDIR /tmp
RUN \ 
    wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    # Install node
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

RUN \
    mkdir -p /root/go

ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

### Creating Directories
RUN \
    cd /home &&\
    mkdir -p tools_web_vapt tools_osint tools_mobile_vapt tools_red_teaming tools_forensics wordlist binaries

## Environment for Directories
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt/
ENV TOOLS_OSINT=/home/tools_osint/
ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/
ENV TOOLS_RED_TEAMING=/home/tools_red_teaming/
ENV TOOLS_FORENSICS=/home/tools_forensics/
ENV TOOLS_GIT_RECON=/home/tools_git_recon/
ENV WORDLIST=/home/wordlist/
ENV BINARIES=/home/binaries/
ENV METASPLOIT_CONFIG=/home/metasploit_config/
ENV METASPLOIT_TOOL=/home/metasploit
ENV GREP_PATTERNS=/home/grep_patterns/
ENV GO111MODULE=on
### Creating Directory for grep patterns
WORKDIR ${GREP_PATTERNS}

RUN \
    mkdir -p ${GREP_PATTERNS}/.gf &&\
    git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git ${GREP_PATTERNS}/.gf/    

### Tools for Web and Network VAPT
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
    #git clone joomscan
    git clone --depth 1  https://github.com/rezasp/joomscan.git && \
    # git clone massdns
    git clone --depth 1 https://github.com/blechschmidt/massdns.git && \
    # git clone strike
    git clone --depth 1 https://github.com/s0md3v/Striker.git && \
    # git clone LinkFinder
    git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git &&  \
    # git clone massscan
    git clone --depth 1 https://github.com/robertdavidgraham/masscan && \
    #git clone Spiderfoot
    git clone --depth 1 https://github.com/smicallef/spiderfoot.git && \
    #git clone sublister
    git clone --depth 1 https://github.com/aboul3la/Sublist3r.git &&\
    #git clone jwt_tool
    git clone --depth 1 https://github.com/ticarpi/jwt_tool.git

### Installing Tools 
## Installing JWT_Tool
RUN \
    cd jwt_tool &&\
    python -m venv jwt_tool_env &&\
    jwt_tool_env/bin/pip install -r requirements.txt

## Installing LinkFinder
RUN \
    cd LinkFinder &&\
    python setup.py install
## Download findomain
RUN \
    mkdir findomain &&\
    cd findomain &&\
    wget --quiet https://github.com/Edu4rdSHL/findomain/releases/download/2.1.1/findomain-linux -O findomain && \
    chmod +x findomain &&\
    mv findomain /usr/local/bin/findomain &&\
    rm -rf ../findomain
## Installing subfinder
RUN \
    wget --quiet https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz -O subfinder.tar.gz && \
    tar -xzf subfinder.tar.gz && \
    ln -s /tools/recon/findomain/findomain /usr/bin/findomain && \
    rm subfinder.tar.gz
## Installing dirb
RUN \
    apt-get install -y \
    dirb
### Port Scanning Tools
## Installing nmap
RUN \
    apt-get install -y --no-install-recommends \
    nmap
## Installing massscan
RUN \
    cd masscan \
    make install

### OSINT Tools
RUN \
    pip3 install shodan

### Installing Amass 
RUN \
    wget --quiet https://github.com/OWASP/Amass/releases/download/v3.16.0/amass_linux_amd64.zip -O amass.zip &&\
    unzip amass.zip && \
    cd amass_linux_amd64 && \
    cp amass /usr/local/bin && cd .. && rm -rf amass_linux_amd64 amass.zip

## installing go tools 
RUN \   
    go get -u github.com/lc/gau/v2/cmd/gau@latest && \
    go get -u github.com/tomnomnom/qsreplace && \
    go get -u github.com/tomnomnom/gf && \
    go get -u github.com/tomnomnom/httprobe && \
    go get -u github.com/tomnomnom/assetfinder && \
    go get github.com/tomnomnom/waybackurls && \
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest && \
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && \
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
### Installing Impact toolkit for Red-Team 
WORKDIR ${TOOLS_RED_TEAMING}
RUN \
    #Git clone of impacket toolkit
    git clone --depth 1 https://github.com/SecureAuthCorp/impacket.git

    #installing impact tool
RUN \
    cd impacket &&\
    python setup.py build &&\
    python setup.py install

## Wordlist for exploitation
WORKDIR ${WORDLIST}
## git cloning from repo
RUN \
    git clone --depth 1  https://github.com/xmendez/wfuzz.git && \
    git clone --depth 1  https://github.com/danielmiessler/SecLists.git && \
    git clone --depth 1  https://github.com/fuzzdb-project/fuzzdb.git && \
    git clone --depth 1  https://github.com/daviddias/node-dirbuster.git && \
    git clone --depth 1  https://github.com/v0re/dirb.git && \
    curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && \
    curl -L -o all.txt https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt && \
    curl -L -o fuzz.txt https://raw.githubusercontent.com/Bo0oM/fuzz.txt/master/fuzz.txt

## All binaries will store here
WORKDIR ${BINARIES}
## INstallation stuff
RUN \
    wget -L https://github.com/RAJANAGORI/Nightingale/blob/main/binary/ttyd?raw=true -O ttyd && \
    chmod +x ttyd

## All Mobile (Android and iOS) VAPT support
WORKDIR ${TOOLS_MOBILE_VAPT}

RUN \ 
    # Git cloning of MobSf
    git clone --depth 1 https://github.com/MobSF/Mobile-Security-Framework-MobSF.git

RUN \
    cd Mobile-Security-Framework-MobSF && \
    python -m venv venv &&\
    venv/bin/pip install -r requirements.txt

RUN \
    apt-get -f install -y --no-install-recommends \
    apktool \
    adb

## Installing forensics tools
RUN \
    apt-get -f install -y --no-install-recommends \
    exiftool \
    steghide \
    binwalk \
    foremost 

### Installing Network tools
RUN \
    apt-get -f install -y --no-install-recommends \
    traceroute \
    telnet \
    net-tools \
    iputils-ping \
    tcpdump \
    openvpn \
    whois \
    host \
    ####### Extra
    tor \
    john \
    cewl \
    hydra \
    medusa \
    figlet \
    sudo 

# RUN \
#     # you can create a public URL for your application running locally without exposing it to the internet.
#     npm install -g localtunnel

WORKDIR ${METASPLOIT_TOOL}
### Installing Metasploit-framework start here
## PosgreSQL DB
COPY ./configuration/msf-configuration/scripts/db.sql ${METASPLOIT_CONFIG}}

## Startup script
COPY ./configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
## Installation of msf framework
RUN \
    wget -L https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -O msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall
## DB config
COPY ./configuration/msf-configuration/conf/database.yml ${METASPLOIT_CONFIG}/metasploit-framework/config/ 

CMD "./configuration/msf-configuration/scripts/init.sh"

# Expose the service ports
EXPOSE 5432
EXPOSE 9990-9999
EXPOSE 8000-9000
EXPOSE 5001
EXPOSE 7681

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*
### Working Directory of tools ends here
WORKDIR /home