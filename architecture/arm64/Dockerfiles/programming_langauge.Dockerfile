# Stage 1: Base stage
FROM --platform=linux/arm64/v8 debian:latest as base

# Install common dependencies
RUN apt-get update -y --fix-missing && \
    apt-get -f --no-install-recommends install -y \
    wget \
    tar \
    make \
    gcc

# Stage 2: Python 2 stage
FROM --platform=linux/arm64/v8 python:2.7-slim as python2

#Stage 3: Python3 stage 
FROM --platform=linux/arm64/v8 python:3.10.12-slim as python3
RUN \
    apt-get update && \
# Install Python 3 and related packages from the Debian repositories
    apt-get -f --no-install-recommends install -y \
    python3-full \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-openssl \
    python3-distutils

# Create a virtual environment for Python 3
RUN \
    python3 -m venv /opt/venv3 &&\
    pip3 install --user pipx
# Activate the virtual environment
ENV PATH "/opt/venv3/bin:$PATH"

# Install any Python 3 packages that you need
RUN pip install --upgrade pip
RUN pip install setuptools==58.2.0
# Add more pip install commands as needed

# Stage 4: Build Ruby dependencies
FROM --platform=linux/arm64/v8 ruby:3.0.3-slim as ruby-builder
# Install Nokogiri for Ruby
RUN gem install nokogiri

# Stage 5: Build Go dependencies
FROM base as go-builder

WORKDIR /home
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates &&\
    wget -q https://go.dev/dl/go1.21.5.linux-arm64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Stage 6: Java stage
FROM base as java

WORKDIR /home
# Download and install the OpenJDK 17 DEB package from the Oracle website
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates &&\
    wget https://download.oracle.com/java/21/latest/jdk-21_linux-aarch64_bin.tar.gz &&\
    tar -xzf jdk-21_linux-aarch64_bin.tar.gz


# Stage 7: Final stage
FROM --platform=linux/arm64/v8 debian:latest as nightingale-programming-multi-stage

COPY configuration/nodejs/node-installation-script.sh /temp/node-installation-script.sh

RUN apt-get update -y --fix-missing &&\
# Installing essential Library
    apt-get -f --no-install-recommends install -y \
    wget \
    tar \
    make \
    gcc \
    cmake \
    software-properties-common \
    ca-certificates \
    build-essential \
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
    libbz2-dev \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    python3-full \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-openssl \
    python3-distutils \
    pipx

# Copy only the necessary files and directories from the Python 2 and Python 3 stages
# COPY --from=python2 /opt/venv2 /opt/venv2
COPY --from=python2 /usr/local/bin/python2.7 /usr/local/bin/python2.7
# COPY --from=python3 /opt/venv3 /opt/venv3
COPY --from=python3 /usr/bin/python3 /usr/bin/python3
# Copy only the necessary files and directories from the Go image
COPY --from=go-builder /usr/local/ /usr/local/
COPY --from=go-builder /home/ /home/
# Copy only the necessary files and directories from the Java image
COPY --from=java /home/jdk-21.0.2/ /usr/bin/java/

# Set the environment variables for Python 2 and Python 3
ENV PATH "/opt/venv2/bin:/opt/venv3/bin:$PATH"
ENV PYTHON2 "/usr/local/bin/python2.7"
ENV PYTHON3 "/usr/bin/python3"

# Set environment variables for Go
ENV GOROOT "/usr/local/go"
ENV GOPATH "/home/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

# Set environment variable for Java
ENV JAVA_HOME "/usr/bin/java/"