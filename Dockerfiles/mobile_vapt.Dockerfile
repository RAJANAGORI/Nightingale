## Taking Image from Docker Hub for Programming language support
FROM rajanagori/nightingale_programming_image:v1
ARG DEBIAN_FRONTEND=noninteractive

COPY \
    shells/ /temp

COPY \
    configuration/modules-installation/rms-install-modules.sh /temp/rms-install-module.sh

## Installing tools using apt-get for web vapt
RUN \
    true \
    apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler &&\
    bash /temp/node-installation-script.sh &&\
    # Creating Directories
    cd /home && \
    mkdir -p tools_mobile_vapt 

ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/

# All Mobile (Android and iOS) VAPT support
WORKDIR ${TOOLS_MOBILE_VAPT}

RUN \ 
    # Git cloning of MobSf
    git clone --depth 1 https://github.com/MobSF/Mobile-Security-Framework-MobSF.git && \
    # Installing RMS-Runtime-Mobile-Security tool idea by github user m2sup3rn0va and repo name RMS-Runtime-Mobile-Security
    git clone --depth 1 https://github.com/m0bilesecurity/RMS-Runtime-Mobile-Security.git rms

COPY \
    configuration/nodejs-pm2-configuration/pm2-rms.json rms/pm2-rms.json

RUN \
    # Installing MobSF
    cd Mobile-Security-Framework-MobSF && \
    python3 -m venv venv &&\
    ./setup.sh &&\
    cd .. && \
    
    # Installing RMS-Runtime-Mobile-Security
    chmod +x /temp/rms-install-module.sh && \
    /temp/rms-install-module.sh && \

    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /home
