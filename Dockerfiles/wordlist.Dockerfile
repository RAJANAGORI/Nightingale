# Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:development
ARG DEBIAN_FRONTEND=noninteractive

# Installing tools using apt-get
RUN apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    curl \
    wget && \
    # Creating Directories
    mkdir -p /home/wordlist

ENV WORDLIST=/home/wordlist/

# Wordlist for exploitation
WORKDIR ${WORDLIST}

# Git cloning wordlists
RUN git clone --depth 1 https://github.com/xmendez/wfuzz.git && \
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb.git && \
    git clone --depth 1 https://github.com/daviddias/node-dirbuster.git && \
    git clone --depth 1 https://github.com/v0re/dirb.git && \
    curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && \
    # Cleaning Unwanted libraries
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home