# Stage 1: Build Python 2 dependencies
FROM --platform=linux/amd64 debian:buster-slim as python2-builder

COPY configuration/nodejs/node-installation-script.sh /temp/node-installation-script.sh

RUN apt-get update -y --fix-missing

# Installing essential packages for Python 2
RUN apt-get -f --no-install-recommends install -y \
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
    openjdk-17-jre \
    openjdk-17-jdk \
    libbz2-dev \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev

# Stage 2: Build Python 3 dependencies
FROM python:3.10.12-slim as python3-builder

COPY configuration/nodejs/node-installation-script.sh /temp/node-installation-script.sh

# Install essential build tools for Python 3
RUN apt-get update -y --fix-missing && \
    apt-get -f --no-install-recommends install -y \
    build-essential

# Stage 3: Build Ruby dependencies
FROM ruby:3.0.3-slim as ruby-builder

# Install Nokogiri for Ruby
RUN gem install nokogiri

# Stage 4: Build Go dependencies
FROM golang:1.17.2-alpine as go-builder

WORKDIR /home

# Install additional dependencies for Go
RUN apk add --no-cache wget libssl-dev

# Set environment variable to disable cgo
ENV CGO_ENABLED=0

# Stage 5: Final image
FROM debian:buster-slim

# Copy only the necessary files and directories from the Python 2 image
COPY --from=python2-builder /usr/local/ /usr/local/

# Copy only the necessary files and directories from the Python 3 image
COPY --from=python3-builder /usr/local/ /usr/local/
COPY --from=python3-builder /temp/ /temp/

# Copy only the necessary files and directories from the Ruby image
COPY --from=ruby-builder /usr/local/ /usr/local/

# Copy only the necessary files and directories from the Go image
COPY --from=go-builder /usr/local/ /usr/local/
COPY --from=go-builder /home/ /home/

# Set environment variables for Go
ENV GOROOT "/usr/local/go"
ENV GOPATH "/home/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"