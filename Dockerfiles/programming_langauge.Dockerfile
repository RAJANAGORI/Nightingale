FROM debian:latest

COPY configuration/nodejs/node-installation-script.sh /temp/node-installation-script.sh

RUN apt-get update -y --fix-missing

# Installing essential packages
RUN apt-get -f --no-install-recommends install -y \
    software-properties-common \
    ca-certificates \
    build-essential \
    wget \
    curl \
    git \
    vim \
    nano \
    make \
    cmake \
    ruby \
    ruby-bundler \
    ruby-dev \
    ruby-full \
    ftp \
    bundler \
    autoconf \
    automake \
    dialog apt-utils \
    libantlr3-runtime-java \
    libcurl4-openssl-dev \
    libexpat1-dev \
    libguava-java \
    libiconv-hook1 \
    libiconv-hook-dev \
    libjson-c-dev \
    liblzma-dev \
    libpcap-dev \
    libpq-dev \
    libruby \
    libsmali-java \
    libsqlite3-dev \
    libssl-dev \
    libstringtemplate-java \
    libwebsockets-dev \
    libwww-perl \
    libxmlunit-java \
    libxpp3-java \
    libyaml-snake-java \
    libz-dev \
    linux-libc-dev \
    libev-* \
    libev4 \
    libffi-dev \
    openjdk-17-jre \
    openjdk-17-jdk \
    libbz2-dev \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev 

RUN \
    wget https://www.python.org/ftp/python/3.12.1/Python-3.12.1.tgz &&\
    tar -xzf Python-3.12.1.tgz &&\
    cd Python-3.12.1 &&\
    ./configure --enable-optimizations &&\
    make &&\
    make install
    
RUN \
    apt-get -f --no-install-recommends install -y \
    python3-full \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-openssl

# Installing Python
RUN python3 -m pip install --upgrade pip && \
    pip install setuptools==58.2.0 pipx

# Installing Nokogiri for Ruby
RUN gem install nokogiri

# Install go and node
WORKDIR /home
RUN wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

RUN chmod +x /temp/node-installation-script.sh &&\
    /temp/node-installation-script.sh
    
# Cleanup
RUN rm -rf /home/* && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*

# Environment variables
ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"
