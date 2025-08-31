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
    pipx && \
### Creating Directories
    cd /home &&\
    mkdir -p tools_network_vapt

ENV TOOLS_NETWORK_VAPT=/home/tools_network_vapt/

WORKDIR ${TOOLS_NETWORK_VAPT}

# git clonning of tools repository
RUN git clone --depth 1 https://github.com/sullo/nikto.git  &&\
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home