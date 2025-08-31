# Stage 1: Base stage
FROM debian:stable-slim AS base

# Install common dependencies
RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
    wget \
    tar \
    make \
    gcc \
    ca-certificates \
    build-essential

# Stage 2: Python 2 stage
# Removed Python 2 stage as it is deprecated and not recommended for use.
# FROM python:3.13-slim AS python2 

# Stage 3: Python 3 stage
FROM python:3.12.11-slim AS python3

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    python -m venv /opt/venv3 --copies && \
    /opt/venv3/bin/pip install --upgrade pip setuptools==58.2.0 pipx

# Stage 4: Ruby stage
FROM ruby:3.4.5-slim AS ruby-builder

RUN gem install nokogiri

# Stage 5: Go stage
FROM base AS go-builder

WORKDIR /home
RUN wget -q https://go.dev/dl/go1.23.2.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Stage 6: Java stage
FROM openjdk:26-jdk-oracle AS java

# Stage 7: Final stage
FROM debian:stable-slim AS final

COPY configuration/nodejs-env/node-installation-script.sh /temp/node-installation-script.sh

RUN apt-get update -y --fix-missing && \
    apt-get install -y --no-install-recommends \
    wget \
    unzip \
    tar \
    make \
    gcc \
    cmake \
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
    libev4 \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    pipx


# Copy necessary files from other stages
# Removed Python 2 environment variable as it is deprecated
# COPY --from=python2 /usr/local/bin/python2.7 /usr/local/bin/python2.7
COPY --from=python3 /opt/venv3 /opt/venv3
COPY --from=python3 /usr/local/lib/ /usr/local/lib/
COPY --from=python3 /usr/local/bin/ /usr/local/bin/
COPY --from=go-builder /usr/local/go /usr/local/go
COPY --from=go-builder /home /home
COPY --from=java /usr/java/openjdk-26 /usr/java/openjdk-26

# Set environment variables
# Removed Python 2 environment variable as it is deprecated
# ENV PYTHON2="/usr/local/bin/python2.7"
ENV PYTHON3="/opt/venv3/bin/python"
ENV GOROOT="/usr/local/go"
ENV GOPATH="/home/go"
ENV JAVA_HOME="/usr/java/openjdk-26"
ENV PATH="/opt/venv3/bin:$GOPATH/bin:$GOROOT/bin:$JAVA_HOME:$PATH"
