# Stage 1: Base Image with Dependencies
FROM ghcr.io/rajanagori/nightingale_programming_image:stable AS base

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"

ARG DEBIAN_FRONTEND=noninteractive

# Install essential packages only, remove unnecessary ones for size optimization
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        # Core utilities (minimal set)
        ca-certificates \
        # Build tools (will be removed later)
        build-essential cmake \
        # Essential system tools
        tree zsh figlet unzip dos2unix \
        # Network utilities (essential only)
        curl wget git \
        # Security tools (core only)
        nmap htop \
        # Mobile testing (essential)
        adb apktool \
        # Forensics (essential)
        exiftool steghide binwalk foremost \
        # Database client only
        postgresql-client \
        # Python tools
        pipx; \
    # Clean up immediately
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    # Verify critical tools
    command -v git >/dev/null || { echo "git not installed"; exit 1; }; \
    command -v curl >/dev/null || { echo "curl not installed"; exit 1; }

# Stage 2: Copy Scripts and Configurations
FROM base AS intermediate

COPY shells/banner.sh /tmp/banner.sh
COPY configuration/nodejs-env/ /temp/

RUN set -eux; \
    dos2unix ${HOME}/.bashrc; \
    cat /tmp/banner.sh >> ${HOME}/.bashrc; \
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
    python-install-modules; \
    go-install-modules; \
    # Clean up module installation scripts to save space
    rm -f ${SHELLS}/python-install-modules.sh ${SHELLS}/go-install-modules.sh

WORKDIR ${BINARIES}
COPY binary/ ${BINARIES}

RUN set -eux; \
    chmod +x ${BINARIES}/*; \
    mv ${BINARIES}/* /usr/local/bin/; \
    # Install ttyd with minimal dependencies
    wget -q -L https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -O /usr/local/bin/ttyd; \
    chmod +x /usr/local/bin/ttyd; \
    # Install trufflehog with minimal approach
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin; \
    # Clean up binaries directory
    rm -rf ${BINARIES}/*; \
    # Verify installations
    ttyd --version && trufflehog --version

## Metasploit stage: setup Metasploit configuration and scripts
FROM modules AS metasploit

WORKDIR ${METASPLOIT_TOOL}
COPY configuration/msf-configuration/scripts/db.sql .
COPY configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
COPY configuration/msf-configuration/conf/database.yml ${METASPLOIT_CONFIG}/metasploit-framework/config/

# Stage 5: Final Image
FROM metasploit AS final

EXPOSE 5432 8080 8081 7681

COPY configuration/cve-mitigation/vuln-library-purge /tmp/vuln-library-purge 

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    # Remove build dependencies to reduce size
    apt-get purge -y build-essential cmake gcc g++ make 2>/dev/null || true; \
    # Remove unnecessary packages
    apt-get purge -y \
        linux-libc-dev \
        libc6-dev \
        libstdc++-14-dev \
        libgcc-14-dev \
        cpp-14 \
        gcc-14 \
        2>/dev/null || true; \
    # Clean up package cache and temporary files
    apt-get autoremove -y --purge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/*; \
    # Remove documentation and man pages to save space
    find /usr/share -name "*.md" -delete 2>/dev/null || true; \
    find /usr/share -name "*.txt" -delete 2>/dev/null || true; \
    find /usr/share -name "*.html" -delete 2>/dev/null || true; \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* 2>/dev/null || true; \
    # Clean up Python cache
    find /usr -name "*.pyc" -delete 2>/dev/null || true; \
    find /usr -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true; \
    # Clean up Go cache
    go clean -cache -modcache -testcache 2>/dev/null || true; \
    # Remove .git directories from tools to save space
    find ${TOOLS_WEB_VAPT} ${TOOLS_OSINT} ${TOOLS_MOBILE_VAPT} ${TOOLS_NETWORK_VAPT} ${TOOLS_RED_TEAMING} ${TOOLS_FORENSICS} ${WORDLIST} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    # Set up final environment
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    echo 'export PAGER="less -R -X -F -K"' >> ~/.bashrc; \
    echo 'help() { command "$@" --help 2>/dev/null | less -R -X -F -K || command "$@"; }' >> ~/.bashrc; \
    echo 'alias h="help"' >> ~/.bashrc

WORKDIR /home