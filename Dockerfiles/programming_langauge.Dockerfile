FROM debian:latest
# COPY \
#     configuration/source /tmp/source

COPY \
    shells/node-installation-script.sh /temp/node-installation-script.sh

RUN \
    # cat /tmp/source >> /etc/apt/sources.list && \
    apt-get update -y --fix-missing && \
    apt-get upgrade -y &&\
### Programming Language Support
    apt-get -f --no-install-recommends install -y \
    ## Essentials
    software-properties-common \
    ca-certificates \
    ca-certificates-java\
    build-essential \
    wget \
    curl \
    ## Dev Essentials
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
    # ## Database Support
    # postgresql \
    # postgresql-client \
    # postgresql-contrib \
    ## Essentials Library Support
    libantlr3-runtime-java \
    libcurl4-openssl-dev \
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
    # #Installing Python3
    python3-pip \
    python3-venv \
    python3-dev \
    python3-full \
    libssl-dev \
    libffi-dev \
    #installing java
    openjdk-17-jre \
    openjdk-17-jdk

# RUN \
    # wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz &&\
    # tar -xzf Python-3.11.2.tgz &&\
    # cd Python-3.11.2 &&\
    # ./configure --enable-optimizations &&\
    # make &&\
    # make install &&\
    # wget https://files.pythonhosted.org/packages/c7/42/be1c7bbdd83e1bfb160c94b9cafd8e25efc7400346cf7ccdbdb452c467fa/setuptools-68.0.0-py3-none-any.whl &&\
    # pip3 install setuptools-68.0.0-py3-none-any.whl
#     python3 -m pip install --upgrade pip

RUN \
    ## Installing Nokogiri to parse any HTML and XMl in RUBY
    gem install nokogiri
RUN \
# Installing go Language
    mkdir -p /root/go

# Install go and node
WORKDIR /home
RUN \ 
    wget -q https://go.dev/dl/go1.20.7.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz &&\
    # Install node
    bash /temp/node-installation-script.sh && \
    rm -rf /home/* &&\
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /var/cache/apt/archives/* &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"