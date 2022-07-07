FROM debian:latest

RUN \
    apt-get update -y && \
### Programming Language Support
    apt-get -f --no-install-recommends install -y \
    ## Essentials
    software-properties-common \
    ca-certificates \
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

    ## Database Support
    postgresql \
    postgresql-client \
    postgresql-contrib \

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

    #Installing Python3
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev &&\
    python3 -m pip install --upgrade pip &&\

    #installing java
    apt-get install -y --no-install-recommends \
    default-jre-headless \
    default-jdk-headless &&\

    ## Installing Nokogiri to parse any HTML and XMl in RUBY
    gem install nokogiri &&\
    #removing the unnecessary packages
    rm -rf /home/* &&\
    apt-get -y autoremove &&\
    apt-get -y clean &&\
    rm -rf /tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -rf /var/cache/apt/archives/* &&\
# Installing go Language
    mkdir -p /root/go /usr/local/nvm

# nvm environment variables
ENV NVM_DIR = /usr/local/nvm
ENV NODE_VERSION = 16.14.0
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
 
# Install go and node
WORKDIR /home
RUN \ 
    wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    # Install node
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION

ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"
