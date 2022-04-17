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
# Some android architecture dependency
    android-framework-res \
# installing Apktool and adb
    adb \
    apktool && \
    pip install objection

RUN \
    cd /home && \
    mkdir -p tools_mobile_vapt

ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/

# All Mobile (Android and iOS) VAPT support
WORKDIR ${TOOLS_MOBILE_VAPT}

RUN \ 
    # Git cloning of MobSf
    git clone --depth 1 https://github.com/MobSF/Mobile-Security-Framework-MobSF.git

RUN \
    cd Mobile-Security-Framework-MobSF && \
    python3 -m venv venv &&\
    venv/bin/pip install -r requirements.txt

WORKDIR /home

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*
