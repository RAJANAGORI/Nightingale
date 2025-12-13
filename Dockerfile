###############################################################################
# Nightingale: Docker for Pentesters - AMD64 Architecture
# Description: Multi-stage build for comprehensive pentesting environment
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
# GitHub: https://github.com/RAJANAGORI/Nightingale
# Architecture: AMD64 / x86_64 (Intel, AMD, etc.)
###############################################################################

# syntax=docker/dockerfile:1.4

# Stage 1: Base Image with Dependencies
FROM ghcr.io/rajanagori/nightingale_programming_image:stable AS base

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale AMD64" \
      org.opencontainers.image.description="Docker image for penetration testing with 100+ security tools (AMD64)" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.documentation="https://github.com/RAJANAGORI/Nightingale/wiki" \
      org.opencontainers.image.version="2.0.0" \
      architecture="amd64"

# Build arguments for flexibility
ARG DEBIAN_FRONTEND=noninteractive

# Install essential packages only, remove unnecessary ones for size optimization
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        bash ca-certificates build-essential cmake locate snapd tree zsh figlet unzip p7zip-full ftp ssh git curl wget file nano vim dirb nmap htop traceroute telnet net-tools iputils-ping tcpdump openvpn whois host tor john cewl hydra medusa dnsutils android-framework-res adb apktool exiftool steghide binwalk foremost dos2unix postgresql postgresql-client postgresql-contrib pipx pv hashcat hashcat-data; \
    # Clean up immediately
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    # Verify critical tools
    command -v git >/dev/null || { echo "git not installed"; exit 1; }; \
    command -v curl >/dev/null || { echo "curl not installed"; exit 1; }; \
    command -v bash >/dev/null || { echo "bash not installed"; exit 1; }

###############################################################################
# Stage 2: Configuration and Scripts
###############################################################################
FROM base AS intermediate

# Copy banner script
COPY --chmod=755 shells/banner.sh /tmp/banner.sh

# Copy Node.js configuration
COPY configuration/nodejs-env/ /temp/

RUN set -eux; \
    dos2unix ${HOME}/.bashrc; \
    cat /tmp/banner.sh >> ${HOME}/.bashrc; \
    echo 'main' >> ${HOME}/.bashrc; \
    mkdir -p /home/tools_web_vapt /home/tools_osint /home/tools_mobile_vapt /home/tools_network_vapt \
        /home/tools_red_teaming /home/tools_forensics /home/wordlist /home/binaries /home/.gf /home/.shells; \
    # Clean up temporary files
    rm -f /tmp/banner.sh

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
    SHELLS=/home/.shells

# # Add custom binaries to PATH
ENV PATH="${PATH}:/home/.local/bin:${BINARIES}:/home/go/bin"

# Copy tool collections from pre-built AMD64 images
COPY --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable ${TOOLS_WEB_VAPT} ${TOOLS_WEB_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable ${GREP_PATTERNS} ${GREP_PATTERNS}
COPY --from=ghcr.io/rajanagori/nightingale_osint_tools_image:stable ${TOOLS_OSINT} ${TOOLS_OSINT}
COPY --from=ghcr.io/rajanagori/nightingale_mobile_vapt_image:stable ${TOOLS_MOBILE_VAPT} ${TOOLS_MOBILE_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_network_vapt_image:stable ${TOOLS_NETWORK_VAPT} ${TOOLS_NETWORK_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable ${TOOLS_RED_TEAMING} ${TOOLS_RED_TEAMING}
COPY --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable ${TOOLS_FORENSICS} ${TOOLS_FORENSICS}
COPY --from=ghcr.io/rajanagori/nightingale_wordlist_image:stable ${WORDLIST} ${WORDLIST}


## Modules stage: install Python and Go modules, setup binaries and additional tools
FROM intermediate AS modules

COPY configuration/modules-installation/python-install-modules.sh ${SHELLS}/python-install-modules.sh
COPY configuration/modules-installation/go-install-modules.sh ${SHELLS}/go-install-modules.sh

RUN set -eux; \
    dos2unix ${SHELLS}/python-install-modules.sh ${SHELLS}/go-install-modules.sh; \
    chmod +x ${SHELLS}/python-install-modules.sh ${SHELLS}/go-install-modules.sh; \
    ln -s ${SHELLS}/python-install-modules.sh /usr/local/bin/python-install-modules; \
    ln -s ${SHELLS}/go-install-modules.sh /usr/local/bin/go-install-modules; \
    mkdir -p /home/go/bin /home/go/pkg; \
    export GOPATH="/home/go"; \
    python-install-modules; \
    go-install-modules; \
    # Clean up module installation scripts to save space
    rm -f ${SHELLS}/python-install-modules.sh ${SHELLS}/go-install-modules.sh

WORKDIR ${BINARIES}
COPY binary/ ${BINARIES}

RUN set -eux; \
    # Remove ttyd from binaries since it's incompatible with current OpenSSL version
    # We'll build it from source with proper library linking
    rm -f ${BINARIES}/ttyd; \
    chmod +x ${BINARIES}/*; \
    mv ${BINARIES}/* /usr/local/bin/; \
    # Install trufflehog with minimal approach
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin; \
    # Verify installation
    trufflehog --version

# Build ttyd from source - the binary is incompatible with OpenSSL 3.x
# First build libwebsockets with libuv support, then build ttyd
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        wget \
        unzip \
        libuv1-dev \
        libssl-dev \
        zlib1g-dev \
        libjson-c-dev \
        libcap-dev \
        libzstd-dev \
        git \
        && rm -rf /var/lib/apt/lists/* && \
    # Build libwebsockets from source with libuv support
    cd /tmp && \
    git clone --depth 1 --branch v4.3-stable https://github.com/warmcat/libwebsockets.git libwebsockets-src && \
    cd libwebsockets-src && \
    mkdir build && cd build && \
    cmake .. -DLWS_WITH_LIBUV=ON -DLWS_WITH_LIBEVENT=OFF -DLWS_WITH_LIBEV=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd /tmp && rm -rf libwebsockets-src && \
    # Now build ttyd
    wget -L https://github.com/tsl0922/ttyd/archive/refs/tags/1.7.7.zip && \
    unzip 1.7.7.zip && \
    cd ttyd-1.7.7 && mkdir build && cd build && \
    cmake .. -DLWS_WITH_LIBUV=ON -DLWS_WITH_LIBEVENT=OFF -DLWS_WITH_LIBEV=OFF -DCMAKE_BUILD_TYPE=Release && \
    make && make install && \
    cd /tmp && rm -rf ttyd-1.7.7 1.7.7.zip && \
    # Verify ttyd installation and that it can find required libraries
    command -v ttyd >/dev/null || { echo "ERROR: ttyd build failed"; exit 1; }; \
    ttyd --version || { echo "ERROR: ttyd cannot run - library dependency issue"; exit 1; }

## Metasploit stage: setup Metasploit configuration and scripts
FROM modules AS metasploit

WORKDIR ${METASPLOIT_TOOL}
COPY  configuration/msf-configuration/scripts/db.sql .
COPY configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
COPY configuration/msf-configuration/conf/database.yml ${METASPLOIT_CONFIG}/metasploit-framework/config/

# Stage 5: Final Image
FROM metasploit AS final

EXPOSE 3000 5432 8080 8081 7681

COPY configuration/cve-mitigation/vuln-library-purge /tmp/vuln-library-purge 

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    grep -Ev '^\s*(#|$)' /tmp/vuln-library-purge | while read -r pkg; do \
      if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then \
        echo "Purging $pkg"; \
        apt-get purge -y "$pkg" || echo "WARN: purge failed for $pkg (continuing)"; \
      else \
        echo "Skipping $pkg (not installed)"; \
      fi; \
    done; \
    apt-get autoremove -y --purge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ; \
    # Remove documentation and man pages to save space
    find /usr/share -name "*.md" -delete 2>/dev/null || true; \
    find /usr/share -name "*.txt" -delete 2>/dev/null || true; \
    find /usr/share -name "*.html" -delete 2>/dev/null || true; \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* 2>/dev/null || true; \
    # Remove .git directories from tools to save space
    find ${TOOLS_WEB_VAPT} ${TOOLS_OSINT} ${TOOLS_MOBILE_VAPT} ${TOOLS_NETWORK_VAPT} ${TOOLS_RED_TEAMING} ${TOOLS_FORENSICS} ${WORDLIST} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true;

COPY --from=ghcr.io/rajanagori/nightingale_programming_image:stable /usr/local /usr/local
COPY --from=ghcr.io/rajanagori/nightingale_programming_image:stable /opt/venv3 /opt/venv3
COPY --from=ghcr.io/rajanagori/nightingale_programming_image:stable /usr/local/go /home/go
COPY --from=ghcr.io/rajanagori/nightingale_programming_image:stable /usr/java/openjdk-26 /usr/java/openjdk-26

WORKDIR /home

# Add final metadata
LABEL org.opencontainers.image.base.name="ghcr.io/rajanagori/nightingale_programming_image:stable" \
      org.opencontainers.image.ref.name="stable" \
      stage="final"

###############################################################################
# Build Instructions:
# docker buildx build --platform linux/amd64 \
#   -f Dockerfile \
#   -t nightingale:stable .
#
# Architecture: AMD64 / x86_64 (Intel, AMD, etc.)
###############################################################################