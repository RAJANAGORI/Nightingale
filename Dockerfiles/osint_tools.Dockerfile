## Taking Image from Docker Hub for Programming language support
FROM rajanagori/nightingale_programming_image:v1
## Installing tools using apt-get for web vapt
RUN \
    apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler && \
### Creating Directories
    cd /home && \
    mkdir -p tools_osint

ENV TOOLS_OSINT=/home/tools_osint/

WORKDIR ${TOOLS_OSINT}

# git clonning of the tools
RUN \
    # Git clone of reconspider
    git clone --depth 1 https://github.com/bhavsec/reconspider.git && \
    # Git clone of recon-ng
    git clone --depth 1 https://github.com/lanmaster53/recon-ng.git && \

### INstalling tools
# Installing reconspider
    cd reconspider && \
    python3 setup.py install &&\
    cd ../ && \
    cd recon-ng && \
    pip install -r REQUIREMENTS && \
    cd ../ && \
    
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /home