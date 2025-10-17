###############################################################################
# Nightingale: Docker for Pentesters - Main Dockerfile
# Description: Multi-stage build for comprehensive pentesting environment
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL 3.0
# GitHub: https://github.com/RAJANAGORI/Nightingale
###############################################################################

# Stage 1: Base Image with Dependencies
FROM ghcr.io/rajanagori/nightingale_programming_image:stable-optimized AS base

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale" \
      org.opencontainers.image.description="Docker image for penetration testing with 100+ security tools" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.documentation="https://github.com/RAJANAGORI/Nightingale/wiki" \
      org.opencontainers.image.version="2.0.0" \
      maintainer="Raja Nagori" \
      email="raja.nagori@owasp.org"

# Build arguments for flexibility
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DATE
ARG VCS_REF

# Add build metadata
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}"

# Install system dependencies with security best practices
# hadolint ignore=DL3008,DL3009
RUN set -eux; \
    # Update package lists
    apt-get update -y; \
    # Install packages
    apt-get install -y --no-install-recommends \
        # Core utilities
        ca-certificates \
        # Build tools (will be removed in final stage)
        build-essential cmake \
        # Libraries required for ttyd runtime
        libuv1 \
        # System tools
        locate tree zsh figlet dos2unix pv \
        # Compression tools
        unzip p7zip-full \
        # Network services
        ftp ssh openvpn tor \
        # Development tools
        git curl wget \
        # Text editors
        nano vim \
        # File analysis
        file \
        # Security testing tools
        dirb nmap htop john cewl hydra medusa hashcat \
        # Network utilities
        traceroute telnet net-tools iputils-ping tcpdump whois host dnsutils \
        # Mobile testing
        android-framework-res adb apktool \
        # Forensics
        exiftool steghide binwalk foremost \
        # Database (client only for security)
        postgresql-client \
        # Python tools
        pipx; \
    # Clean up to reduce image size
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    # Verify critical commands installed
    command -v git >/dev/null || { echo "git not installed"; exit 1; }; \
    command -v curl >/dev/null || { echo "curl not installed"; exit 1; }

###############################################################################
# Stage 2: Configuration and Scripts
###############################################################################
FROM base AS intermediate

# Copy banner script
COPY --chmod=755 shells/banner.sh /tmp/banner.sh

# Copy Node.js configuration
COPY configuration/nodejs-env/ /temp/

# Setup environment and directories
RUN set -eux; \
    # Convert line endings for cross-platform compatibility
    dos2unix "${HOME}/.bashrc" 2>/dev/null || true; \
    # Add banner to bashrc
    cat /tmp/banner.sh >> "${HOME}/.bashrc"; \
    # Create directory structure
    mkdir -p \
        /home/tools_web_vapt \
        /home/tools_osint \
        /home/tools_mobile_vapt \
        /home/tools_network_vapt \
        /home/tools_red_teaming \
        /home/tools_forensics \
        /home/wordlist \
        /home/binaries \
        /home/.gf \
        /home/.shells

# Environment variables for tool locations
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt \
    BINARIES=/home/binaries \
    GREP_PATTERNS=/home/.gf \
    TOOLS_OSINT=/home/tools_osint \
    TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt \
    TOOLS_NETWORK_VAPT=/home/tools_network_vapt \
    TOOLS_RED_TEAMING=/home/tools_red_teaming \
    TOOLS_FORENSICS=/home/tools_forensics \
    WORDLIST=/home/wordlist \
    METASPLOIT_CONFIG=/home/metasploit_config \
    METASPLOIT_TOOL=/home/metasploit \
    SHELLS=/home/.shells \
    GOPATH=/root/go

# Add custom binaries to PATH
ENV PATH="${PATH}:/root/.local/bin:${BINARIES}:/root/go/bin"

# Copy tool collections from pre-built images
COPY --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable-optimized ${TOOLS_WEB_VAPT} ${TOOLS_WEB_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable-optimized ${GREP_PATTERNS} ${GREP_PATTERNS}
COPY --from=ghcr.io/rajanagori/nightingale_osint_tools_image:stable-optimized ${TOOLS_OSINT} ${TOOLS_OSINT}
COPY --from=ghcr.io/rajanagori/nightingale_mobile_vapt_image:stable-optimized ${TOOLS_MOBILE_VAPT} ${TOOLS_MOBILE_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_network_vapt_image:stable-optimized ${TOOLS_NETWORK_VAPT} ${TOOLS_NETWORK_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable-optimized ${TOOLS_RED_TEAMING} ${TOOLS_RED_TEAMING}
COPY --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable-optimized ${TOOLS_FORENSICS} ${TOOLS_FORENSICS}
COPY --from=ghcr.io/rajanagori/nightingale_wordlist_image:stable-optimized ${WORDLIST} ${WORDLIST}

## Modules stage: install Python and Go modules, setup binaries and additional tools
FROM intermediate AS modules

COPY configuration/modules-installation/python-install-modules.sh ${SHELLS}/python-install-modules.sh
COPY configuration/modules-installation/go-install-modules.sh ${SHELLS}/go-install-modules.sh

RUN dos2unix ${SHELLS}/python-install-modules.sh \
    && dos2unix ${SHELLS}/go-install-modules.sh \
    && chmod +x ${SHELLS}/python-install-modules.sh ${SHELLS}/go-install-modules.sh \
    && ln -s ${SHELLS}/python-install-modules.sh /usr/local/bin/python-install-modules \
    && ln -s ${SHELLS}/go-install-modules.sh /usr/local/bin/go-install-modules \
    && mkdir -p /root/go/bin /root/go/pkg \
    && export GOPATH="/root/go" \
    && python-install-modules \
    && go-install-modules

WORKDIR ${BINARIES}
COPY binary/ ${BINARIES}

RUN chmod +x ${BINARIES}/* \
    && mv ${BINARIES}/* /usr/local/bin/ \
    && wget -q -O trufflehog.tar.gz https://github.com/trufflesecurity/trufflehog/releases/download/v3.90.10/trufflehog_3.90.10_linux_amd64.tar.gz \
    && tar -xzf trufflehog.tar.gz -C /usr/local/bin/ trufflehog \
    && chmod +x /usr/local/bin/trufflehog \
    && rm trufflehog.tar.gz \
    # Install ttyd using system package (most compatible approach)
    && apt-get update \
    && apt-get install -y ttyd \
    && ttyd --version

## Metasploit stage: setup Metasploit configuration and scripts
FROM modules AS metasploit

WORKDIR ${METASPLOIT_TOOL}
COPY --chmod=644 configuration/msf-configuration/scripts/db.sql .
COPY --chmod=755 configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
COPY --chmod=600 configuration/msf-configuration/conf/database.yml ${METASPLOIT_CONFIG}/metasploit-framework/config/

# Stage 5: Final Image
FROM metasploit AS final

EXPOSE 5432 8080 8081 7681

COPY configuration/cve-mitigation/vuln-library-purge /tmp/vuln-library-purge 

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    grep -Ev '^\s*(#|$)' /tmp/vuln-library-purge | while read -r pkg; do \
      dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed' && apt-get purge -y "$pkg" || true; \
    done; \
    apt-get purge -y build-essential gcc g++ make 2>/dev/null || true; \
    apt-get autoremove -y --purge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/*; \
    find /usr/share -name "*.pyc" -delete 2>/dev/null || true; \
    find /usr/share -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true; \
    go clean -cache -modcache -testcache 2>/dev/null || true; \
    find ${TOOLS_WEB_VAPT} ${TOOLS_OSINT} ${TOOLS_MOBILE_VAPT} ${TOOLS_NETWORK_VAPT} ${TOOLS_RED_TEAMING} ${TOOLS_FORENSICS} ${WORDLIST} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    echo 'export PATH="$PATH:/root/.local/bin:/root/go/bin"' >> ~/.bashrc; \
    echo 'export PAGER="less -R -X -F -K"' >> ~/.bashrc; \
    echo 'help() { command "$@" --help 2>/dev/null | less -R -X -F -K || command "$@"; }' >> ~/.bashrc; \
    echo 'alias h="help"' >> ~/.bashrc

WORKDIR /home

# # Add healthcheck
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#     CMD ttyd --version || exit 1

# # Set default command
# CMD ["ttyd", "--writable", "-p", "7681", "--max-clients", "10", "bash"]

# Add final metadata
LABEL org.opencontainers.image.base.name="ghcr.io/rajanagori/nightingale_programming_image:stable-optimized" \
      org.opencontainers.image.ref.name="stable-optimized" \
      stage="final"