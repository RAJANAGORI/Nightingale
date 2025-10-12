###############################################################################
# Nightingale Network VAPT Tools Image
# Description: Docker image with network vulnerability assessment tools
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
###############################################################################

# Base image with programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:arm64

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale Network VAPT" \
      org.opencontainers.image.description="Network vulnerability assessment tools for Nightingale" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.vendor="OWASP" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="network-vapt"

# Build argument
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        git \
        make \
        cmake \
        bundler \
        pipx \
        perl; \
    # Create directory for tools
    mkdir -p /home/tools_network_vapt; \
    # Verify directory
    test -d /home/tools_network_vapt || exit 1; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variable
ENV TOOLS_NETWORK_VAPT=/home/tools_network_vapt

# Set working directory
WORKDIR ${TOOLS_NETWORK_VAPT}

# Clone and install network scanning tools
RUN set -eux; \
    echo "Installing Nikto web server scanner..."; \
    # Clone Nikto
    git clone --depth 1 https://github.com/sullo/nikto.git; \
    # Remove .git folder to save space
    rm -rf nikto/.git; \
    # Make nikto executable
    chmod +x nikto/program/nikto.pl 2>/dev/null || true; \
    # Verify cloning
    test -d nikto || exit 1; \
    echo "Nikto installed successfully"

# Final cleanup and configuration
RUN set -eux; \
    # Remove build dependencies
    apt-get purge -y \
        build-essential \
        make \
        cmake 2>/dev/null || true; \
    # Aggressive cleanup
    apt-get autoremove -y --purge; \
    apt-get clean; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/* \
        /tmp/* \
        /var/tmp/* \
        /root/.cache/*; \
    # Add tools to PATH
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    fi; \
    if ! grep -q 'nikto' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:${TOOLS_NETWORK_VAPT}/nikto/program"' >> ~/.bashrc; \
    fi; \
    echo "Network VAPT tools setup complete"

# Set working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -d /home/tools_network_vapt/nikto || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Included Tools:
# - Nikto: Web server scanner for dangerous files, outdated software, etc.
#
# Usage:
# docker build -f Dockerfiles/network_vapt.Dockerfile \
#   -t nightingale_network_vapt_image:stable .
###############################################################################
