###############################################################################
# Nightingale Wordlists Image
# Description: Docker image with comprehensive wordlists for security testing
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
###############################################################################

# Base image with programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale Wordlists" \
      org.opencontainers.image.description="Comprehensive wordlists for security testing" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.vendor="OWASP" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="wordlists"

# Build argument
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        gzip; \
    # Create directory for wordlists
    mkdir -p /home/wordlist; \
    # Verify directory
    test -d /home/wordlist || exit 1; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Set environment variable
ENV WORDLIST=/home/wordlist/

# Set working directory for wordlist installation
WORKDIR ${WORDLIST}

# Download and clone wordlist collections
RUN set -eux; \
    echo "Downloading wordlists..."; \
    # Clone wfuzz wordlists
    git clone --depth 1 https://github.com/xmendez/wfuzz.git; \
    rm -rf wfuzz/.git; \
    # Clone SecLists (comprehensive security wordlists)
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git; \
    rm -rf SecLists/.git; \
    # Clone fuzzdb
    git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb.git; \
    rm -rf fuzzdb/.git; \
    # Clone node-dirbuster
    git clone --depth 1 https://github.com/daviddias/node-dirbuster.git; \
    rm -rf node-dirbuster/.git; \
    # Clone dirb
    git clone --depth 1 https://github.com/v0re/dirb.git; \
    rm -rf dirb/.git; \
    echo "Wordlists cloned successfully"

# Download RockYou wordlist
RUN set -eux; \
    echo "Downloading RockYou wordlist..."; \
    curl -L -o rockyou.txt.gz \
        https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt || \
    wget -q -O rockyou.txt.gz \
        https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt || \
    echo "Warning: RockYou download failed"; \
    # Decompress if downloaded successfully
    if [ -f rockyou.txt.gz ]; then \
        gunzip rockyou.txt.gz 2>/dev/null || mv rockyou.txt.gz rockyou.txt; \
    fi; \
    echo "RockYou wordlist processed"

# Final cleanup and configuration
RUN set -eux; \
    # Remove build dependencies
    apt-get purge -y \
        git 2>/dev/null || true; \
    # Aggressive cleanup
    apt-get autoremove -y --purge; \
    apt-get clean; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/* \
        /tmp/* \
        /var/tmp/* \
        /root/.cache/*; \
    # Add wordlist directory to bashrc
    if ! grep -q 'WORDLIST' ~/.bashrc 2>/dev/null; then \
        echo 'export WORDLIST=/home/wordlist/' >> ~/.bashrc; \
    fi; \
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    fi; \
    # Display wordlist summary
    echo "Wordlists installed:"; \
    ls -1 /home/wordlist/ || true; \
    echo "Wordlist setup complete"

# Set working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -d /home/wordlist/SecLists || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Included Wordlists:
# - wfuzz: Wordlists for web fuzzing
# - SecLists: Comprehensive security testing wordlists
# - fuzzdb: Dictionary of attack patterns and primitives
# - node-dirbuster: Directory and file brute-forcing lists
# - dirb: Web content scanner wordlists
# - rockyou.txt: Popular password wordlist
#
# Usage:
# docker build -f Dockerfiles/wordlist.Dockerfile \
#   -t nightingale_wordlist_image:stable .
###############################################################################
