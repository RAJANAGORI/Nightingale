## Taking Image from Docker Hub for Programming language support
FROM rajanagori/nightingale_programming_image:v1

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"

## Banner shell and run shell file ##
COPY \
    shells/banner.sh /tmp/banner.sh

COPY \
    configuration/source /tmp/source

RUN \
    cat /tmp/banner.sh >> /root/.bashrc && \
    cat /tmp/source >> /etc/apt/sources.list 

USER root

#### Installing os tools and other dependencies.
RUN \
    apt-get -y update --fix-missing && \
    apt-get -y upgrade && \
    apt-get -f install -y \
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
    wget

### Creating Directories
RUN \
    cd /home &&\
    mkdir -p tools_web_vapt tools_osint tools_mobile_vapt tools_network_vapt tools_red_teaming tools_forensics wordlist binaries .gf

## Environment for Directories
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt/
ENV BINARIES=/home/binaries/
ENV GREP_PATTERNS=/home/.gf
ENV TOOLS_OSINT=/home/tools_osint/
ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/
ENV TOOLS_NETWORK_VAPT=/home/tools_network_vapt/
ENV TOOLS_RED_TEAMING=/home/tools_red_teaming/
ENV TOOLS_FORENSICS=/home/tools_forensics/
ENV WORDLIST=/home/wordlist/
ENV METASPLOIT_CONFIG=/home/metasploit_config/
ENV METASPLOIT_TOOL=/home/metasploit

COPY \
    --from=rajanagori/nightingale_web_vapt_image:v1.0 ${TOOLS_WEB_VAPT} ${TOOLS_WEB_VAPT}
COPY \
    --from=rajanagori/nightingale_web_vapt_image:v1.0 ${BINARIES} ${BINARIES}
COPY \
    --from=rajanagori/nightingale_web_vapt_image:v1.0 ${GREP_PATTERNS} ${GREP_PATTERNS}
COPY \
    --from=rajanagori/nightingale_osint_image:v1.0 ${TOOLS_OSINT} ${TOOLS_OSINT}
COPY \
    --from=rajanagori/nightingale_mobile_vapt_image:v1.0 ${TOOLS_MOBILE_VAPT} ${TOOLS_MOBILE_VAPT}
COPY \
    --from=rajanagori/nightingale_network_vapt_image:v1.0 ${TOOLS_NETWORK_VAPT} ${TOOLS_NETWORK_VAPT}
COPY \
    --from=rajanagori/nightingale_forensic_and_red_teaming:v1.0 ${TOOLS_RED_TEAMING} ${TOOLS_RED_TEAMING}
COPY \
    --from=rajanagori/nightingale_forensic_and_red_teaming:v1.0 ${TOOLS_FORENSICS} ${TOOLS_FORENSICS}

# Wordlist for exploitation
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

## Installing metasploit
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
