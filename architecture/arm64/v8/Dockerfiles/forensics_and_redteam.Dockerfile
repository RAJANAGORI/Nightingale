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
# Create directories for tools
    mkdir -p /home/tools_red_teaming /home/tools_forensics

# Set environment variables
ENV TOOLS_RED_TEAMING=/home/tools_red_teaming \
    TOOLS_FORENSICS=/home/tools_forensics

## Installing Impact toolkit for Red-Team 
WORKDIR ${TOOLS_RED_TEAMING}
RUN \
    python3 -m pipx install impacket &&\
    pipx ensurepath

RUN \
    # Cleaning Unwanted libraries 
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home