# Stage 1: Base stage
FROM debian:buster-slim as base

# Install common dependencies
RUN apt-get update -y --fix-missing && \
    apt-get -f --no-install-recommends install -y \
    wget \
    tar \
    make \
    gcc

# Stage 2: Python 2 stage
FROM base as python2

# Download, extract, configure, and install Python 2.7
RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
    tar -xzf Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure --enable-optimizations && \
    make && \
    make install

# Create a virtual environment for Python 2.7
RUN python2.7 -m venv /opt/venv2
# Activate the virtual environment
ENV PATH "/opt/venv2/bin:$PATH"

# Install any Python 2 packages that you need
RUN pip install --upgrade pip
RUN pip install setuptools==58.2.0
# Add more pip install commands as needed

# Stage 3: Python 3 stage
FROM base as python3
RUN \
    wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz &&\
    tar -xzf Python-3.10.12.tgz &&\
    cd Python-3.10.12 &&\
    ./configure --enable-optimizations &&\
    make &&\
    make install
    
# Install Python 3 and related packages from the Debian repositories
RUN apt-get update -y --fix-missing && \
    apt-get -f --no-install-recommends install -y \
    python3-full \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-openssl \
    python3-distutils

# Create a virtual environment for Python 3
RUN python3 -m venv /opt/venv3
# Activate the virtual environment
ENV PATH "/opt/venv3/bin:$PATH"

# Install any Python 3 packages that you need
RUN pip install --upgrade pip
RUN pip install setuptools==58.2.0
# Add more pip install commands as needed

# Stage 4: Build Ruby dependencies
FROM ruby:3.0.3-slim as ruby-builder

# Install Nokogiri for Ruby
RUN gem install nokogiri

# Stage 5: Build Go dependencies
FROM golang:1.17.2-alpine as go-builder

# Stage 6: Java stage
FROM base as java

# Download and install the OpenJDK 17 DEB package from the Oracle website
RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb && \
    dpkg -i jdk-17_linux-x64_bin.deb

# Stage 7: Final stage
FROM --platform=linux/amd64 debian:buster-slim as nightingale-programming-multi-stage

COPY configuration/nodejs/node-installation-script.sh /temp/node-installation-script.sh

RUN apt-get update -y --fix-missing &&\
# Installing essential Library
    apt-get -f --no-install-recommends install -y \
    wget \
    tar \
    make \
    gcc \
    software-properties-common \
    ca-certificates \
    build-essential \
    libcurl4-openssl-dev \
    libexpat1-dev \
    # libguava-java \
    libiconv-hook1 \
    libiconv-hook-dev \
    libjson-c-dev \
    liblzma-dev \
    libpcap-dev \
    libpq-dev \
    libruby \
    # libsmali-java \
    libsqlite3-dev \
    libssl-dev \
    # libstringtemplate-java \
    libwebsockets-dev \
    libwww-perl \
    # libxmlunit-java \
    # libxpp3-java \
    # libyaml-snake-java \
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
    tk-dev

# Copy only the necessary files and directories from the Python 2 and Python 3 stages
COPY --from=python2 /opt/venv2 /opt/venv2
COPY --from=python2 /usr/local/bin/python2.7 /usr/local/bin/python2.7
COPY --from=python3 /opt/venv3 /opt/venv3
COPY --from=python3 /usr/bin/python3 /usr/bin/python3
# Copy only the necessary files and directories from the Go image
COPY --from=go-builder /usr/local/ /usr/local/
COPY --from=go-builder /home/ /home/
# Copy only the necessary files and directories from the Java image
COPY --from=java /usr/lib/jvm /usr/lib/jvm
COPY --from=java /usr/bin/java /usr/bin/java

# Set the environment variables for Python 2 and Python 3
ENV PATH "/opt/venv2/bin:/opt/venv3/bin:$PATH"
ENV PYTHON2 "/usr/local/bin/python2.7"
ENV PYTHON3 "/usr/bin/python3"

# Set environment variables for Go
ENV GOROOT "/usr/local/go"
ENV GOPATH "/home/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

# Set environment variable for Java
ENV JAVA_HOME "/usr/lib/jvm/java-17-openjdk-amd64"