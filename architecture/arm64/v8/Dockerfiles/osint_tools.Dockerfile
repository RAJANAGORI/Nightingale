###############################################################################
# Nightingale OSINT Tools Image
# Description: Docker image with Open Source Intelligence gathering tools
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
###############################################################################

# Base image with programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:arm64-optimized

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale OSINT Tools" \
      org.opencontainers.image.description="Open Source Intelligence gathering tools for Nightingale" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \ 
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="osint-tools"

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
        libxml2 \
        libxslt1-dev \
        pipx \
        python3-venv; \
    # Create directory for OSINT tools
    mkdir -p /home/tools_osint; \
    # Verify directory
    test -d /home/tools_osint || exit 1; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Set environment variable
ENV TOOLS_OSINT=/home/tools_osint

# Set working directory
WORKDIR ${TOOLS_OSINT}

# Clone OSINT tools
RUN set -eux; \
    echo "Cloning OSINT tools..."; \
    # Clone recon-ng
    git clone --depth 1 https://github.com/lanmaster53/recon-ng.git; \
    # Clone metagoofil
    git clone --depth 1 https://github.com/opsdisk/metagoofil.git; \
    # Remove .git folders to save space
    rm -rf recon-ng/.git metagoofil/.git; \
    # Verify cloning
    test -d recon-ng || exit 1; \
    test -d metagoofil || exit 1; \
    echo "OSINT tools cloned successfully"

# Install recon-ng dependencies
RUN set -eux; \
    echo "Installing recon-ng..."; \
    cd recon-ng; \
    if [ -f REQUIREMENTS ]; then \
        while IFS= read -r package || [ -n "${package}" ]; do \
            # Skip empty lines and comments
            [ -z "${package}" ] || echo "${package}" | grep -q '^#' && continue; \
            echo "Installing ${package}..."; \
            pip3 install --no-cache-dir "${package}" 2>&1 || echo "Warning: ${package} installation failed"; \
        done < REQUIREMENTS; \
    fi; \
    cd ..; \
    echo "recon-ng dependencies installed"

# Install metagoofil dependencies
RUN set -eux; \
    echo "Installing metagoofil..."; \
    cd metagoofil; \
    if [ -f requirements.txt ]; then \
        python3 -m venv venv; \
        # Install dependencies
        while IFS= read -r package || [ -n "${package}" ]; do \
            # Skip empty lines and comments
            [ -z "${package}" ] || echo "${package}" | grep -q '^#' && continue; \
            echo "Installing ${package}..."; \
            pipx install --include-deps "${package}" 2>&1 || echo "Warning: ${package} installation failed"; \
        done < requirements.txt; \
    fi; \
    cd ..; \
    echo "metagoofil dependencies installed"

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
        /root/.cache/* \
        /root/.local/pipx/.cache; \
    # Add tools to PATH
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    fi; \
    if ! grep -q 'tools_osint' ~/.bashrc 2>/dev/null; then \
        echo 'export TOOLS_OSINT=/home/tools_osint' >> ~/.bashrc; \
    fi; \
    echo "OSINT tools setup complete"

# Set final working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -d /home/tools_osint/recon-ng && test -d /home/tools_osint/metagoofil || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Included Tools:
# - recon-ng: Full-featured reconnaissance framework
# - metagoofil: Metadata extraction tool
#
# Usage:
# docker build -f Dockerfiles/osint_tools.Dockerfile \
#   -t nightingale_osint_tools_image:arm64-optimized .
###############################################################################
