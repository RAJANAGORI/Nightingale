# Pulling the base image
FROM debian:latest

LABEL maintainer="Raja Nagori" \
      email="rajanagori19@gmail.com"

USER root

# Installing os tools and other dependencies.
RUN \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -f install -y --no-install-recommends \
    htop \
    unzip \
    locate \
    p7zip-full \
    vim \
    ftp \
    libcurl4-openssl-dev \
    libssl-dev \
    libwww-perl \
    dos2unix\
    ssh \
    git \
    ruby \
    ruby-dev \
    bundler \
    bison \
    flex \
    autoconf \
    automake \
    ruby-full \
    libcurl4-openssl-dev \
    make \
    software-properties-common \
    curl \
    ca-certificates \
    gnupg \
    libz-dev \
    libiconv-hook1 \
    libiconv-hook-dev \  
    build-essential \
    patch \
    ruby-bundler \
    zlib1g-dev \
    liblzma-dev \
    autoconf \
    libpcap-dev \
    libpq-dev \
    libsqlite3-dev \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    dialog apt-utils \
    nasm \
    wget \
    smbclient \
    dirb \
    nmap \ 
    tor \
    john \
    cewl \
    hydra \
    medusa \
    figlet \
    sudo

RUN \
    gem install nokogiri 

# Banner shell and run shell file
COPY \
    shells/banner.sh /tmp/banner.sh
RUN \
    cat /tmp/banner.sh >> /root/.bashrc

# Installing Dependencies and tools for kali linux environment 
RUN \
    apt-get install -y \
    python3-pip \
    python3-dev &&\
    cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    pip3 install --upgrade pip

# Installing Python dependencies
COPY requirements.txt /tmp

RUN \
    pip3 install -r /tmp/requirements.txt

# Install go
WORKDIR /tmp
RUN \
    wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
# Install node
    curl -sL https://deb.nodesource.com/setup_14.x | bash && \
    apt install -y nodejs
# Install Perl 
ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

#Working Directory of tools
RUN \
    cd /home/$USER &&\
    mkdir tool-for-pentester &&\
    cd tool-for-pentester

WORKDIR \
    /home/tool-for-pentester/

#git cloning of the wordlist
RUN \
    mkdir wordlists &&\
    cd wordlists &&\
    git clone  https://github.com/xmendez/wfuzz.git && \
    git clone  https://github.com/danielmiessler/SecLists.git && \
    git clone  https://github.com/fuzzdb-project/fuzzdb.git && \
    git clone  https://github.com/daviddias/node-dirbuster.git && \
    git clone  https://github.com/v0re/dirb.git && \
    curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && \
    curl -L -o all.txt https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt && \
    curl -L -o fuzz.txt https://raw.githubusercontent.com/Bo0oM/fuzz.txt/master/fuzz.txt

#git clonning 
RUN \
    # Git clone of SqlMap
    git clone https://github.com/sqlmapproject/sqlmap.git &&\
    # Git clone of HawkScan
    git clone https://github.com/c0dejump/HawkScan.git &&\
    #Git clone of impacket toolkit
    git clone https://github.com/SecureAuthCorp/impacket.git &&\
    #Git clone Assetfinder
    git clone https://github.com/tomnomnom/assetfinder.git &&\
    #git clone of xsstrike
    git clone https://github.com/s0md3v/XSStrike.git &&\
    #git clone whatweb
    git clone https://github.com/urbanadventurer/WhatWeb.git && \
    #git clone dirsearch
    git clone  https://github.com/maurosoria/dirsearch.git && \
    #git clone arjun
    git clone  https://github.com/s0md3v/Arjun.git && \
    #git clone joomscan
    git clone  https://github.com/rezasp/joomscan.git && \
    # git clone massdns
    git clone https://github.com/blechschmidt/massdns.git && \
    # git clone strike
    git clone https://github.com/s0md3v/Striker.git && \
    # git clone LinkFinder
    git clone https://github.com/GerbenJavado/LinkFinder.git

# Installing LinkFinder
RUN \
    cd LinkFinder &&\
    python setup.py install

# Installing tools
RUN \
    mkdir recon-tools && \
    git clone https://github.com/RAJANAGORI/tool-install-script.git . && \
    chmod +x install.sh && \
    ./install.sh

# Download findomain
RUN \
    mkdir findomain &&\
    cd findomain && \
    wget --quiet https://github.com/Edu4rdSHL/findomain/releases/download/2.1.1/findomain-linux -O findomain && \
    chmod +x findomain

# Installing subfinder
RUN \
    wget --quiet https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz -O subfinder.tar.gz && \
    tar -xzf subfinder.tar.gz && \
    ln -s /tools/recon/findomain/findomain /usr/bin/findomain && \
    rm subfinder.tar.gz

# Installing Shodan
RUN \
    pip3 install shodan

# Installing Impact toolkit for Red-Team 
RUN \
    cd impacket &&\
    python setup.py build &&\
    python setup.py install

# Installing forensic tools
RUN \
    apt-get install -y \
    exiftool \
    steghide \
    binwalk \
    foremost 

# Installing Network tools
RUN \
    apt-get -f install -y --no-install-recommends \
    traceroute \
    telnet \
    net-tools \
    iputils-ping \
    tcpdump \
    openvpn \
    whois \
    host 

# Installing Metasploit-framework
## PosgreSQL DB
COPY ./configuration/msf-configuration/scripts/db.sql /tmp/

## Startup script
COPY ./configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh

## Installation of msf framework
RUN \
    wget -L https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -O msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall
 
## DB config
COPY ./configuration/msf-configuration/conf/database.yml /home/tool-for-pentester/metasploit-framework/config/ 

CMD "./configuration/msf-configuration/scripts/init.sh"

# Expose the service ports
EXPOSE 5432
EXPOSE 9990-9999
EXPOSE 8000-9000

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* 

WORKDIR /