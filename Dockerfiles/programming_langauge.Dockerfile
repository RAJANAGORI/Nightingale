# Stage 1: Base stage
FROM debian:buster-slim AS base

# Install common dependencies
RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
    wget \
    tar \
    make \
    gcc \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Stage 2: Python 2 stage
FROM python:2.7-slim AS python2

# Stage 3: Python 3 stage
FROM python:3.10.12-slim AS python3

# Install Python 3 dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-openssl \
    python3-distutils && \
    pipx \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Reinstall and upgrade pip
RUN python3 -m ensurepip --upgrade && \
    python3 -m pip install --upgrade pip setuptools

# Create a Python 3 virtual environment in /opt/venv3
RUN python3 -m venv /opt/venv3

# Upgrade pip inside the virtual environment
RUN /opt/venv3/bin/pip install --upgrade pip

# Stage 4: Ruby stage
FROM ruby:3.0.3-slim AS ruby-builder

# Install Ruby dependencies
RUN gem install nokogiri && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Stage 5: Go stage
FROM base AS go-builder

# Install Go
WORKDIR /home
RUN wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Stage 6: Java stage
FROM openjdk:23-jdk-oracle AS java

# Stage 7: Final stage
FROM debian:stable-slim AS final

# Copy node installation script
COPY configuration/nodejs-env/node-installation-script.sh /temp/node-installation-script.sh

# Install final stage dependencies
RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
    wget \
    tar \
    make \
    gcc \
    software-properties-common \
    build-essential \
    libcurl4-openssl-dev \
    libexpat1-dev \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libpcap-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libwebsockets-dev \
    llvm \
    tk-dev \
    xz-utils \
    libev4 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy necessary files from other stages
COPY --from=python2 /usr/local/bin/python2.7 /usr/local/bin/python2.7
COPY --from=python2 /usr/local/bin/pip /usr/local/bin/pip2.7
COPY --from=python3 /usr/bin/python3 /usr/bin/python3
COPY --from=python3 /usr/bin/pip3 /usr/bin/pip3
COPY --from=python3 /opt/venv3 /opt/venv3
COPY --from=go-builder /usr/local/go /usr/local/go
COPY --from=java /usr/java/openjdk-23 /usr/java/openjdk-23

# Set environment variables
ENV PATH="/usr/java/openjdk-23/bin:/opt/venv3/bin:/usr/local/go/bin:$PATH"
ENV PYTHON2="/usr/local/bin/python2.7"
ENV PYTHON3="/usr/bin/python3"
ENV GOROOT="/usr/local/go"
ENV GOPATH="/home/go"
ENV JAVA_HOME="/usr/java/openjdk-23"