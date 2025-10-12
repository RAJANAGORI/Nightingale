###############################################################################
# Nightingale Web VAPT Tools Image
# Description: Docker image with comprehensive web application security tools
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
###############################################################################

# Base image with programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable-optimized

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale Web VAPT" \
      org.opencontainers.image.description="Web application security testing tools for Nightingale" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="web-vapt"

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
        unzip \
        whatweb \
        pipx \
        hashcat \
        hashcat-data \
        python3-setuptools; \
    # Create directories
    mkdir -p /home/tools_web_vapt /home/.gf; \
    # Verify directories
    test -d /home/tools_web_vapt || exit 1; \
    test -d /home/.gf || exit 1; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt/ \
    GREP_PATTERNS=/home/.gf/

# Clone GF patterns for grep-friendly filtering
WORKDIR ${GREP_PATTERNS}
RUN set -eux; \
    echo "Cloning GF patterns..."; \
    git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git .; \
    # Remove .git to save space
    rm -rf .git; \
    echo "GF patterns installed"

# Clone web application security tools
WORKDIR ${TOOLS_WEB_VAPT}
RUN set -eux; \
    echo "Cloning web security tools..."; \
    # XSS detection and exploitation
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git; \
    # Parameter discovery
    git clone --depth 1 https://github.com/s0md3v/Arjun.git; \
    # DNS resolver
    git clone --depth 1 https://github.com/blechschmidt/massdns.git; \
    # Web application scanner
    git clone --depth 1 https://github.com/s0md3v/Striker.git; \
    # Endpoint discovery
    git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git; \
    # Subdomain enumeration
    git clone --depth 1 https://github.com/aboul3la/Sublist3r.git; \
    # JWT security testing
    git clone --depth 1 https://github.com/ticarpi/jwt_tool.git; \
    # Web technology fingerprinting
    git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git; \
    # Secret detection
    git clone --depth 1 https://github.com/gitleaks/gitleaks.git; \
    # SQL injection tool
    git clone --depth 1 https://github.com/r0oth3x49/ghauri.git; \
    # Remove all .git folders to save significant space
    find . -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    echo "Web security tools cloned"

# Install Arjun (Parameter Discovery)
RUN set -eux; \
    echo "Installing Arjun..."; \
    cd Arjun; \
    pipx install arjun || echo "Warning: Arjun installation failed"; \
    cd ..

# Install LinkFinder (Endpoint Discovery)
RUN set -eux; \
    echo "Installing LinkFinder..."; \
    cd LinkFinder; \
    if [ -f requirements.txt ]; then \
        while IFS= read -r package || [ -n "${package}" ]; do \
            [ -z "${package}" ] || echo "${package}" | grep -q '^#' && continue; \
            pipx install "${package}" 2>&1 || echo "Warning: ${package} failed"; \
        done < requirements.txt; \
    fi; \
    cd ..

# Install Striker (Web Scanner)
RUN set -eux; \
    echo "Installing Striker..."; \
    cd Striker; \
    if [ -f requirements.txt ]; then \
        while IFS= read -r package || [ -n "${package}" ]; do \
            [ -z "${package}" ] || echo "${package}" | grep -q '^#' && continue; \
            pipx install --include-deps "${package}" 2>&1 || echo "Warning: ${package} failed"; \
        done < requirements.txt; \
    fi; \
    cd ..

# Install dirsearch (Directory Scanner)
RUN set -eux; \
    echo "Installing dirsearch..."; \
    pipx install dirsearch || echo "Warning: dirsearch installation failed"

# Install jwt_tool (JWT Security)
RUN set -eux; \
    echo "Installing jwt_tool..."; \
    cd jwt_tool; \
    if [ -f requirements.txt ]; then \
        pip3 install --no-cache-dir -r requirements.txt --break-system-packages || \
        echo "Warning: jwt_tool dependencies failed"; \
    fi; \
    cd ..

# Install Sublist3r (Subdomain Enumeration)
RUN set -eux; \
    echo "Installing Sublist3r..."; \
    cd Sublist3r; \
    pipx install Sublist3r || echo "Warning: Sublist3r installation failed"; \
    cd ..

# Install XSStrike (XSS Detection)
RUN set -eux; \
    echo "Installing XSStrike..."; \
    cd XSStrike; \
    if [ -f requirements.txt ]; then \
        while IFS= read -r package || [ -n "${package}" ]; do \
            [ -z "${package}" ] || echo "${package}" | grep -q '^#' && continue; \
            pipx install "${package}" 2>&1 || echo "Warning: ${package} failed"; \
        done < requirements.txt; \
    fi; \
    cd ..

# Install Trufflehog (Secret Detection)
RUN set -eux; \
    echo "Installing Trufflehog..."; \
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | \
    sh -s -- -b /usr/local/bin || echo "Warning: Trufflehog installation failed"

# Build Gitleaks (Git Secret Scanner)
RUN set -eux; \
    echo "Building Gitleaks..."; \
    cd gitleaks; \
    if [ -f Makefile ]; then \
        make build || echo "Warning: Gitleaks build failed"; \
    fi; \
    cd ..

# Install Ghauri (SQL Injection)
RUN set -eux; \
    echo "Installing Ghauri..."; \
    cd ghauri; \
    if [ -f requirements.txt ]; then \
        pip3 install --no-cache-dir -r requirements.txt --break-system-packages || true; \
        pip3 install --no-cache-dir . --break-system-packages || \
        echo "Warning: Ghauri installation failed"; \
    fi; \
    cd ..

# Install Amass (Subdomain Discovery)
RUN set -eux; \
    echo "Installing Amass..."; \
    wget -q https://github.com/owasp-amass/amass/releases/download/v5.0.0/amass_linux_amd64.tar.gz -O amass.tar.gz; \
    tar -xzf amass.tar.gz; \
    mv amass_linux_amd64/amass /usr/local/bin/; \
    rm -rf amass_linux_amd64 amass.tar.gz; \
    # Verify installation
    command -v amass || echo "Warning: Amass not in PATH"

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
    # Add binaries to PATH
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    fi; \
    if ! grep -q 'TOOLS_WEB_VAPT' ~/.bashrc 2>/dev/null; then \
        echo 'export TOOLS_WEB_VAPT=/home/tools_web_vapt/' >> ~/.bashrc; \
    fi; \
    echo "Web VAPT tools setup complete"

# Set working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD test -d /home/tools_web_vapt || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Included Tools:
# - XSStrike: XSS detection and exploitation
# - Arjun: HTTP parameter discovery
# - Striker: Web application scanner
# - LinkFinder: Endpoint discovery
# - Sublist3r: Subdomain enumeration
# - jwt_tool: JWT security testing
# - massdns: High-performance DNS resolver
# - WhatWeb: Web technology fingerprinting
# - Gitleaks: Git secret scanner
# - Trufflehog: Secret detection
# - Ghauri: SQL injection detection and exploitation
# - Amass: Subdomain discovery
# - dirsearch: Web path scanner
# - GF Patterns: Grep-friendly patterns
#
# Usage:
# docker build -f Dockerfiles/web_vapt.Dockerfile \
#   -t nightingale_web_vapt_image:stable .
###############################################################################
