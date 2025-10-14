###############################################################################
# Nightingale Forensics and Red Team Tools Image
# Description: Docker image with forensics and red teaming tools
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
###############################################################################

# Base image with programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable-optimized

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale Forensics & Red Team" \
      org.opencontainers.image.description="Forensics and Red Team tools for Nightingale" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="forensics-redteam"

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
        pipx; \
    # Create directories for tools
    mkdir -p /home/tools_red_teaming /home/tools_forensics; \
    # Verify directories
    test -d /home/tools_red_teaming || exit 1; \
    test -d /home/tools_forensics || exit 1; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables
ENV TOOLS_RED_TEAMING=/home/tools_red_teaming \
    TOOLS_FORENSICS=/home/tools_forensics

# Install Impacket toolkit for Red Team operations
WORKDIR ${TOOLS_RED_TEAMING}

RUN set -eux; \
    echo "Installing Impacket..."; \
    python3 -m pipx install impacket; \
    pipx ensurepath; \
    # Verify installation
    command -v impacket-smbclient >/dev/null || echo "Warning: impacket not in PATH"; \
    echo "Impacket installed successfully"

# Final cleanup and configuration
RUN set -eux; \
    # Remove build dependencies to reduce image size
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
    # Add pipx binaries to PATH
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    fi; \
    echo "Forensics and Red Team tools setup complete"

# Set working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD command -v python3 && command -v pipx || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Included Tools:
# - Impacket: Collection of Python classes for working with network protocols
#
# Usage:
# docker build -f Dockerfiles/forensics_and_redteam.Dockerfile \
#   -t nightingale_forensic_and_red_teaming:stable-optimized .
###############################################################################
