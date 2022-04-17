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
    ####### Extra
    tor \
    john \
    cewl \
    hydra \
    medusa \
    figlet 

### Creating Directories
RUN \
    cd /home &&\
    mkdir -p tools_network_vapt

ENV TOOLS_NETWORK_VAPT=/home/tools_network_vapt/

WORKDIR ${TOOLS_NETWORK_VAPT}

# git clonning of tools repository
RUN \
    # Git clone of masscan
    git clone --depth 1 https://github.com/robertdavidgraham/masscan &&\
    # Git clone of nikto
    git clone --depth 1 https://github.com/sullo/nikto 


RUN \
# INstallation of masscan
    cd masscan && \
    make install && \
    ln -s bin/masscan /usr/local/bin/ && \
    cd ../ && rm -rf masscan

WORKDIR /home

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*
    