###############################################################################
# Nightingale Programming Languages Base Image
# Description: Multi-stage Docker image with Python, Ruby, Go, and Java support
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
# GitHub: https://github.com/RAJANAGORI/Nightingale
###############################################################################

###############################################################################
# Stage 1: Base Build Stage
# Purpose: Common build dependencies
###############################################################################
FROM debian:stable-slim AS base

LABEL stage="base" \
      description="Base stage with common build dependencies"

# Install common build dependencies
RUN set -eux; \
    apt-get update -y --fix-missing; \
    apt-get install -y --no-install-recommends \
        wget \
        tar \
        make \
        gcc \
        ca-certificates \
        build-essential; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

###############################################################################
# Stage 2: Python 3 Environment
# Purpose: Python 3.12 with virtual environment and pipx
###############################################################################
FROM python:3.12.11-slim AS python3

LABEL stage="python3" \
      description="Python 3.12 environment with pipx"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential; \
    # Create optimized virtual environment
    python -m venv /opt/venv3 --copies; \
    # Upgrade pip and install essential tools
    /opt/venv3/bin/pip install --no-cache-dir --upgrade \
        pip \
        setuptools==58.2.0 \
        pipx; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

###############################################################################
# Stage 3: Ruby Environment
# Purpose: Ruby 3.4 with nokogiri gem
###############################################################################
FROM ruby:3.4.5-slim AS ruby-builder

LABEL stage="ruby" \
      description="Ruby 3.4 environment with nokogiri"

RUN set -eux; \
    # Install nokogiri (commonly needed for security tools)
    gem install nokogiri --no-document; \
    # Cleanup gem cache
    rm -rf /root/.gem

###############################################################################
# Stage 4: Go Environment
# Purpose: Go 1.23.2 compiler and tools
###############################################################################
FROM base AS go-builder

LABEL stage="go" \
      description="Go 1.23.2 environment"

WORKDIR /home

# Install Go
RUN set -eux; \
    wget -q https://go.dev/dl/go1.23.2.linux-arm64.tar.gz -O go.tar.gz; \
    tar -C /usr/local -xzf go.tar.gz; \
    rm go.tar.gz; \
    # Verify installation
    /usr/local/go/bin/go version

###############################################################################
# Stage 5: Java Environment
# Purpose: OpenJDK 26 for Java-based security tools
###############################################################################
FROM openjdk:26-jdk-oracle AS java

LABEL stage="java" \
      description="OpenJDK 26 environment"

# Verify Java installation
RUN java -version

###############################################################################
# Stage 6: Final Combined Environment
# Purpose: All programming languages in one optimized image
###############################################################################
FROM debian:stable-slim AS final

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale Programming Image" \
      org.opencontainers.image.description="Multi-language base image for Nightingale pentesting environment" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="final"

# Copy Node.js installation script
COPY configuration/nodejs-env/node-installation-script.sh /temp/node-installation-script.sh

# Allow overriding Node.js version (WeTTY recommends Node >= 18)
ARG NODE_VERSION=v18.20.4
ENV NODE_VERSION=${NODE_VERSION}

# Install runtime dependencies and libraries
# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -y --fix-missing; \
    apt-get install -y --no-install-recommends \
        # Download utilities
        wget curl unzip tar \
        # Version control (required for NVM installation)
        git \
        # Build tools
        make gcc cmake build-essential \
        # Development libraries (alphabetically organized)
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
        # Additional libraries
        libev4 \
        libffi-dev \
        libbz2-dev \
        libreadline-dev \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        # Python package manager
        pipx; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy language environments from build stages
COPY --from=python3 /opt/venv3 /opt/venv3
COPY --from=python3 /usr/local/lib/ /usr/local/lib/
COPY --from=python3 /usr/local/bin/ /usr/local/bin/
COPY --from=go-builder /usr/local/go /usr/local/go
COPY --from=go-builder /home /home
COPY --from=java /usr/java/openjdk-26 /usr/java/openjdk-26

# Set environment variables for all languages
ENV PYTHON3="/opt/venv3/bin/python" \
    GOROOT="/usr/local/go" \
    GOPATH="/root/go" \
    JAVA_HOME="/usr/java/openjdk-26"
ENV PATH="/opt/venv3/bin:$GOPATH/bin:$GOROOT/bin:$JAVA_HOME/bin:$PATH"

# Install Node.js via NVM and expose node/npm globally
RUN set -eux; \
    chmod +x /temp/node-installation-script.sh; \
    bash /temp/node-installation-script.sh; \
    # Link node/npm/npx/pm2 to system PATH for non-login shells
    ln -sf "/root/.nvm/versions/node/${NODE_VERSION}/bin/node" /usr/local/bin/node; \
    ln -sf "/root/.nvm/versions/node/${NODE_VERSION}/bin/npm" /usr/local/bin/npm; \
    ln -sf "/root/.nvm/versions/node/${NODE_VERSION}/bin/npx" /usr/local/bin/npx; \
    if [ -f "/root/.nvm/versions/node/${NODE_VERSION}/bin/pm2" ]; then \
      ln -sf "/root/.nvm/versions/node/${NODE_VERSION}/bin/pm2" /usr/local/bin/pm2; \
    fi; \
    node --version && npm --version

# Ensure Python shared libraries are found
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/python3.conf && ldconfig

# Verify all installations
RUN set -eux; \
    echo "Verifying installations..."; \
    python3 --version; \
    pip --version; \
    go version; \
    java -version; \
    echo "All programming languages installed successfully"

# Set working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 --version && go version || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Build Instructions:
# docker build -f Dockerfiles/programming_langauge.Dockerfile -t nightingale_programming_image:arm64-optimized .
#
# Included Languages:
# - Python 3.12.11
# - Ruby 3.4.5
# - Go 1.23.2
# - Java OpenJDK 26
# - Node.js 18.20.4
#
# Total Size: Optimized multi-stage build
###############################################################################
