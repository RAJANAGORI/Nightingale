## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:development

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"
    
ARG DEBIAN_FRONTEND=noninteractive

# USER root

RUN \
    # cat /tmp/source >> /etc/apt/sources.list &&\
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
    figlet \
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
    # postgresql \
    # postgresql-client \
    # postgresql-contrib \
    libnss-ldap \
    libpam-ldap \
    ldap-utils \
    nscd \
    nginx
    
## Banner shell and run shell file ##
COPY \
    shells/banner.sh /tmp/banner.sh

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN \
    cat /tmp/banner.sh >> ${HOME}/.bashrc &&\
    cat /tmp/banner.sh >> ${HOME}/.zshrc &&\
    dos2unix ${HOME}/.bashrc &&\
    dos2unix ${HOME}/.zshrc

COPY \
    shells/node-installation-script.sh /temp/node-installation-script.sh
RUN \
    dos2unix /temp/node-installation-script.sh && chmod +x /temp/node-installation-script.sh &&\
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
    --from=ghcr.io/rajanagori/nightingale_web_vapt_image:development ${TOOLS_WEB_VAPT} ${TOOLS_WEB_VAPT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_web_vapt_image:development ${GREP_PATTERNS} ${GREP_PATTERNS}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_osint_tools_image:development ${TOOLS_OSINT} ${TOOLS_OSINT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_mobile_vapt_image:development ${TOOLS_MOBILE_VAPT} ${TOOLS_MOBILE_VAPT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_network_vapt_image:development ${TOOLS_NETWORK_VAPT} ${TOOLS_NETWORK_VAPT}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:development ${TOOLS_RED_TEAMING} ${TOOLS_RED_TEAMING} 
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:development ${TOOLS_FORENSICS} ${TOOLS_FORENSICS}
RUN true
COPY \
    --from=ghcr.io/rajanagori/nightingale_wordlist_image:development ${WORDLIST} ${WORDLIST}
RUN true

COPY \
    configuration/modules-installation/python-install-modules.sh ${SHELLS}/python-install-modules.sh

RUN \
    dos2unix ${SHELLS}/python-install-modules.sh && chmod +x ${SHELLS}/python-install-modules.sh

RUN ${SHELLS}/python-install-modules.sh &&\
    /temp/node-installation-script.sh

## All binaries will store here
WORKDIR ${BINARIES}
## INstallation stuff
COPY \
    binary/ ${BINARIES}

RUN \
    chmod +x ${BINARIES}/* && \
    mv ${BINARIES}/* /usr/local/bin/ && \
    apt-get install -y libjson-c-dev libwebsockets-dev && \
    git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && \
    make && make install &&\
    mv ttyd /usr/local/bin &&\
    cd ${BINARIES} && rm -rf ttyd

## Installing metasploit
WORKDIR ${METASPLOIT_TOOL}
### Installing Metasploit-framework start here
## PosgreSQL DB
COPY configuration/msf-configuration/scripts/db.sql .

## Startup script
COPY configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
## Installation of msf framework
RUN \
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall 
## DB config
COPY ./configuration/msf-configuration/conf/database.yml /home/msfuser/.msf4/database.yml

CMD ["dpkg-reconfigure libnss-ldap" && "dpkg-reconfigure libpam-ldap"]

COPY configuration/ldap/ldap.sh /home/.ldap-files/ldap.sh

RUN \
    chmod +x /home/.ldap-files/ldap.sh &&\
    dos2unix /home/.ldap-files/ldap.sh &&\
    /home/.ldap-files/ldap.sh

### Working Directory of tools ends here
WORKDIR /home/

# Expose the service ports
EXPOSE 5432
EXPOSE 8080
EXPOSE 8081
EXPOSE 7681
EXPOSE 8083

RUN \
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*