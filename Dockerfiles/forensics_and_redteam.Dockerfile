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
## Installing tools using apt-get for forensics
    exiftool \
    steghide \
    binwalk \
    foremost

RUN \
    cd /home &&\
    mkdir -p tools_red_teaming tools_forensics

ENV TOOLS_RED_TEAMING=/home/tools_red_teaming/
ENV TOOLS_FORENSICS=/home/tools_forensics/

## Installing Impact toolkit for Red-Team 
WORKDIR ${TOOLS_RED_TEAMING}

RUN \
    #Git clone of impacket toolkit
    git clone --depth 1 https://github.com/SecureAuthCorp/impacket.git

    #installing impact tool
RUN \
    cd impacket &&\
    python3 setup.py build &&\
    python3 setup.py install

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /home
