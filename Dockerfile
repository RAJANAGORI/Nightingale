## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"
    
ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN \
#### Installing os tools and other dependencies.
    apt-get -y update --fix-missing && \
    apt-get -f --no-install-recommends install -y \
    #### Operating system dependecies start
    software-properties-common \
    ca-certificates \
    build-essential \
    ### Operating System Tools start here 
    locate \
    snapd \
    tree \
    zsh \
    figlet \
    ### Compression Techniques starts
    unzip \
    p7zip-full \
    ftp \
    ### Dev Essentials start here
    ssh \
    git \
    curl \
    wget \
    file \
    ### Web Vapt tools using apt-get
    dirb \
    ## INstalling Network Tools using apt-get
    nmap \
    htop \
    traceroute \
    telnet \
    net-tools \
    iputils-ping \
    tcpdump \
    openvpn \
    whois \
    host \
    tor \
    john \
    cewl \
    hydra \
    medusa \
    dnsutils \
    # Some android architecture dependency
    android-framework-res \
    # installing Apktool and adb
    adb \
    apktool \
    ## Installing tools using apt-get for forensics and objection install
    exiftool \
    steghide \
    binwalk \
    foremost \
    dos2unix \
    postgresql \
    postgresql-client \
    postgresql-contrib

## Banner shell and run shell file ##
COPY \
    shells/banner.sh /tmp/banner.sh

COPY \
    configuration/nodejs-env/ /temp/

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN \
    dos2unix ${HOME}/.bashrc &&\
    dos2unix ${HOME}/.zshrc &&\
    cat /tmp/banner.sh >> ${HOME}/.bashrc &&\
    cat /tmp/banner.sh >> ${HOME}/.zshrc &&\
    cat /temp/env_zsh.txt >> ${HOME}/.zshrc

RUN \
### Creating Directories
    cd /home &&\
    mkdir -p tools_web_vapt tools_osint tools_mobile_vapt tools_network_vapt tools_red_teaming tools_forensics wordlist binaries .gf .shells

## Environment for Directories
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt
ENV BINARIES=/home/binaries
ENV GREP_PATTERNS=/home/.gf
ENV TOOLS_OSINT=/home/tools_osint
ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt
ENV TOOLS_NETWORK_VAPT=/home/tools_network_vapt
ENV TOOLS_RED_TEAMING=/home/tools_red_teaming
ENV TOOLS_FORENSICS=/home/tools_forensics
ENV WORDLIST=/home/wordlist
ENV METASPLOIT_CONFIG=/home/metasploit_config
ENV METASPLOIT_TOOL=/home/metasploit
ENV SHELLS=/home/.shells

COPY \
    --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable ${TOOLS_WEB_VAPT} ${TOOLS_WEB_VAPT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable ${GREP_PATTERNS} ${GREP_PATTERNS}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_osint_tools_image:stable ${TOOLS_OSINT} ${TOOLS_OSINT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_mobile_vapt_image:stable ${TOOLS_MOBILE_VAPT} ${TOOLS_MOBILE_VAPT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_network_vapt_image:stable ${TOOLS_NETWORK_VAPT} ${TOOLS_NETWORK_VAPT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable ${TOOLS_RED_TEAMING} ${TOOLS_RED_TEAMING} 
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable ${TOOLS_FORENSICS} ${TOOLS_FORENSICS}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_wordlist_image:stable ${WORDLIST} ${WORDLIST}
RUN true

COPY \
    configuration/modules-installation/python-install-modules.sh ${SHELLS}/python-install-modules.sh

RUN \
    dos2unix ${SHELLS}/python-install-modules.sh && chmod +x ${SHELLS}/python-install-modules.sh &&\
    ${SHELLS}/python-install-modules.sh

## All binaries will store here
WORKDIR ${BINARIES}
## INstallation stuff
COPY \
    binary/ ${BINARIES}
    
RUN \
    chmod +x ${BINARIES}/* && \
    mv ${BINARIES}/* /usr/local/bin/ && \
    wget -L https://github.com/tsl0922/ttyd/archive/refs/tags/1.7.2.zip && \
    unzip 1.7.2.zip &&\
    cd ttyd-1.7.2 && mkdir build && cd build &&\
    cmake .. && make && make install

## Installing metasploit
WORKDIR ${METASPLOIT_TOOL}
### Installing Metasploit-framework start here
## PosgreSQL DB
COPY configuration/msf-configuration/scripts/db.sql .

## Startup script
COPY configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
## Installation of msf framework

RUN \
    wget -q https://github.com/RAJANAGORI/metasploit-multi-os/raw/main/metasploit-framework_6.3.35_amd64.deb -O metasploit.deb &&\
    dpkg -i metasploit.deb

## DB config
COPY ./configuration/msf-configuration/conf/database.yml ${METASPLOIT_CONFIG}/metasploit-framework/config/ 

CMD "./configuration/msf-configuration/scripts/init.sh"

# Expose the service ports
EXPOSE 5432
EXPOSE 8080
EXPOSE 8081
EXPOSE 7681

RUN \
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*

### Working Directory of tools ends here
WORKDIR /home