## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:development
## Installing tools using apt-get for web vapt
RUN \
    apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    curl \
    wget && \
# Creating Directories
    cd /home && \
    mkdir -p wordlist

ENV WORDLIST=/home/wordlist/

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
    curl -L -o fuzz.txt https://raw.githubusercontent.com/Bo0oM/fuzz.txt/master/fuzz.txt && \
    # Cleaning Unwanted libraries
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /var/cache/apt/archives/* &&\
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home