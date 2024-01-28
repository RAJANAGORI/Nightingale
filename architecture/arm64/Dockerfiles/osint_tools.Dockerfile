## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:arm64
## Installing tools using apt-get for web vapt
RUN \
    apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    libxml2 \
    libxslt1-dev && \
### Creating Directories
    cd /home && \
    mkdir -p tools_osint

ENV TOOLS_OSINT=/home/tools_osint/

WORKDIR ${TOOLS_OSINT}

# git clonning of the tools
RUN \
    # Git clone of recon-ng
    git clone --depth 1 https://github.com/lanmaster53/recon-ng.git && \
    #Git clone Spiderfoot
    git clone --depth 1 https://github.com/smicallef/spiderfoot.git && \
    #Git clon metagoofil
    git clone --depth 1 https://github.com/opsdisk/metagoofil &&\
    #Git clone of theharvester
    git clone --depth 1 https://github.com/laramies/theHarvester
### INstalling tools

RUN \
    cd recon-ng && \
    pip3 install -r REQUIREMENTS && \
    cd ..

RUN \
## INstall Spiderfoot
    cd spiderfoot && \
    pip3 install -r requirements.txt &&\
    cd ..
RUN \
    cd metagoofil &&\
    python3 -m venv venv &&\
    pip3 install -r requirements.txt &&\
    cd ..

RUN \
    cd theHarvester &&\
    python3 -m pip install -r requirements/base.txt

RUN \
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /home