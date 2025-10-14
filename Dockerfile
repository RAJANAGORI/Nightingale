###############################################################################
# Nightingale: Docker for Pentesters - Main Dockerfile
# Description: Multi-stage build for comprehensive pentesting environment
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: MIT
# GitHub: https://github.com/RAJANAGORI/Nightingale
###############################################################################

# Stage 1: Base Image with Dependencies
FROM ghcr.io/rajanagori/nightingale_programming_image:stable-optimized AS base

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale" \
      org.opencontainers.image.description="Docker image for penetration testing with 100+ security tools" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.vendor="OWASP" \
      org.opencontainers.image.licenses="MIT" \
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
    command -v curl >/dev/null || { echo "curl not installed"; exit 1; }; \
    echo "Base packages installed successfully"

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
        /home/.shells; \
    # Verify directories created
    test -d /home/tools_web_vapt || { echo "Failed to create directories"; exit 1; }; \
    echo "Environment setup completed"

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
    SHELLS=/home/.shells

# Add custom binaries to PATH
ENV PATH="${PATH}:/root/.local/bin:${BINARIES}"

# Copy tool collections from pre-built images
COPY --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable-optimized ${TOOLS_WEB_VAPT} ${TOOLS_WEB_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_web_vapt_image:stable-optimized ${GREP_PATTERNS} ${GREP_PATTERNS}
COPY --from=ghcr.io/rajanagori/nightingale_osint_tools_image:stable-optimized ${TOOLS_OSINT} ${TOOLS_OSINT}
COPY --from=ghcr.io/rajanagori/nightingale_mobile_vapt_image:stable-optimized ${TOOLS_MOBILE_VAPT} ${TOOLS_MOBILE_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_network_vapt_image:stable-optimized ${TOOLS_NETWORK_VAPT} ${TOOLS_NETWORK_VAPT}
COPY --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable-optimized ${TOOLS_RED_TEAMING} ${TOOLS_RED_TEAMING}
COPY --from=ghcr.io/rajanagori/nightingale_forensic_and_red_teaming:stable-optimized ${TOOLS_FORENSICS} ${TOOLS_FORENSICS}
COPY --from=ghcr.io/rajanagori/nightingale_wordlist_image:stable-optimized ${WORDLIST} ${WORDLIST}

###############################################################################
# Stage 3a: Python Module Installation (Parallel Stage)
# This stage can run in parallel with go-modules stage
###############################################################################
FROM intermediate AS python-modules

# Copy Python module installation script
COPY --chmod=755 configuration/modules-installation/python-install-modules.sh ${SHELLS}/python-install-modules.sh

# Install Python modules
RUN set -eux; \
    # Convert line endings
    dos2unix "${SHELLS}/python-install-modules.sh" || true; \
    # Create symlink for convenience
    ln -sf "${SHELLS}/python-install-modules.sh" /usr/local/bin/python-install-modules; \
    # Run Python installer
    python-install-modules; \
    echo "Python modules installation completed"

###############################################################################
# Stage 3b: Go Module Installation (Parallel Stage)
# This stage can run in parallel with python-modules stage
###############################################################################
FROM intermediate AS go-modules

# Copy Go module installation script
COPY --chmod=755 configuration/modules-installation/go-install-modules.sh ${SHELLS}/go-install-modules.sh

# Install Go modules
RUN set -eux; \
    # Convert line endings
    dos2unix "${SHELLS}/go-install-modules.sh" || true; \
    # Create symlink for convenience
    ln -sf "${SHELLS}/go-install-modules.sh" /usr/local/bin/go-install-modules; \
    # Run Go installer
    go-install-modules; \
    echo "Go modules installation completed"

###############################################################################
# Stage 3c: Combined Modules (Merge Parallel Stages)
# This stage combines the results from both parallel stages
###############################################################################
FROM python-modules AS modules

# Copy Go installations from parallel go-modules stage
# This includes any Go binaries installed to GOPATH/bin
COPY --from=go-modules /home/go /home/go
# COPY --from=go-modules /root/.local /root/.local
COPY --from=go-modules /usr/local/bin/go-install-modules /usr/local/bin/go-install-modules
COPY --from=go-modules ${SHELLS}/go-install-modules.sh ${SHELLS}/go-install-modules.sh

# Verify both installers are available
RUN set -eux; \
    echo "Verifying module installations..."; \
    command -v python-install-modules >/dev/null || echo "Warning: python-install-modules not found"; \
    command -v go-install-modules >/dev/null || echo "Warning: go-install-modules not found"; \
    echo "Module installation stage completed"

# Install binaries and tools
WORKDIR ${BINARIES}
COPY binary/ ${BINARIES}/

# Install binaries and tools (excluding ttyd - built separately)
RUN set -eux; \
    # Make binaries executable and move to PATH
    chmod +x "${BINARIES}"/* || true; \
    mv "${BINARIES}"/* /usr/local/bin/ 2>/dev/null || true; \
    # Install Trufflehog
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin; \
    # Verify installations
    command -v trufflehog >/dev/null || { echo "trufflehog installation failed"; exit 1; }; \
    echo "Tools installation completed"

###############################################################################
# Stage 4: ttyd Builder (Separate Stage for Optimization)
###############################################################################
FROM modules AS ttyd-builder

# Build ttyd in separate stage to avoid leaving build artifacts in final image
RUN set -eux; \
    # Download and build ttyd
    wget -q -L https://github.com/tsl0922/ttyd/archive/refs/tags/1.7.7.zip -O ttyd.zip; \
    unzip -q ttyd.zip; \
    cd ttyd-1.7.7; \
    mkdir build && cd build; \
    cmake .. >/dev/null; \
    make -j"$(nproc)" >/dev/null; \
    # Move binary to temp location for copying
    mv ttyd /tmp/ttyd-binary; \
    cd /; \
    # Clean up build artifacts
    rm -rf /ttyd-1.7.7 /ttyd.zip; \
    echo "ttyd build completed"

###############################################################################
# Stage 5: Metasploit Configuration
###############################################################################
FROM modules AS metasploit

# Setup Metasploit directory
WORKDIR ${METASPLOIT_TOOL}

# Copy Metasploit configuration files
COPY --chmod=644 configuration/msf-configuration/scripts/db.sql ./db.sql
COPY --chmod=755 configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
COPY --chmod=600 configuration/msf-configuration/conf/database.yml ${METASPLOIT_CONFIG}/metasploit-framework/config/database.yml

###############################################################################
# Stage 6: Final Production Image
###############################################################################
FROM metasploit AS final

# Copy ttyd binary from builder stage (saves 50-100MB)
COPY --from=ttyd-builder /tmp/ttyd-binary /usr/local/bin/ttyd
RUN chmod +x /usr/local/bin/ttyd

# Expose required ports with documentation
# 5432: PostgreSQL (Metasploit database)
# 7681: ttyd (web-based terminal)
# 8080: Application main port
# 8081: Alternative application port
EXPOSE 5432 7681 8080 8081

# Copy vulnerability mitigation list
COPY configuration/cve-mitigation/vuln-library-purge /tmp/vuln-library-purge 

# Final cleanup and security hardening with aggressive optimization
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    # Purge vulnerable packages
    echo "Purging vulnerable packages..."; \
    grep -Ev '^\s*(#|$)' /tmp/vuln-library-purge | while read -r pkg; do \
        if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then \
            echo "  Purging: $pkg"; \
            apt-get purge -y "$pkg" 2>/dev/null || echo "  WARN: purge failed for $pkg (continuing)"; \
        fi; \
    done; \
    # Remove build dependencies (saves 200-300MB)
    apt-get purge -y build-essential cmake gcc g++ make 2>/dev/null || true; \
    # Aggressive cleanup (saves 200-400MB)
    apt-get autoremove -y --purge; \
    apt-get clean; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/* \
        /tmp/* \
        /var/tmp/* \
        /root/.cache/* \
        /usr/share/doc/* \
        /usr/share/man/* \
        /usr/share/info/* \
        /usr/share/locale/* \
        /usr/share/zoneinfo/*; \
    # Clean Python caches (saves 50-150MB)
    find /opt/venv3 -name "*.pyc" -delete 2>/dev/null || true; \
    find /opt/venv3 -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true; \
    find /usr/local/lib/python* -name "*.pyc" -delete 2>/dev/null || true; \
    find /usr/local/lib/python* -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true; \
    # Clean Go caches (saves 100-200MB)
    go clean -cache -modcache -testcache 2>/dev/null || true; \
    rm -rf /root/.cache/go-build 2>/dev/null || true; \
    rm -rf /home/go/pkg/mod/cache 2>/dev/null || true; \
    # Remove .git folders from tool directories (saves 200-500MB)
    find ${TOOLS_WEB_VAPT} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    find ${TOOLS_OSINT} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    find ${TOOLS_MOBILE_VAPT} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    find ${TOOLS_NETWORK_VAPT} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    find ${TOOLS_RED_TEAMING} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    find ${TOOLS_FORENSICS} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    find ${WORDLIST} -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true; \
    # Update PATH in bashrc
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    # Final verification
    command -v ttyd >/dev/null || { echo "Final check: ttyd not found"; exit 1; }; \
    command -v nmap >/dev/null || { echo "Final check: nmap not found"; exit 1; }; \
    echo "Final image preparation completed successfully - Optimized for size!"

# Set working directory
WORKDIR /home

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ttyd --version || exit 1

# Set default command
CMD ["/bin/bash"]

# Add final metadata
LABEL org.opencontainers.image.base.name="ghcr.io/rajanagori/nightingale_programming_image:stable-optimized" \
      org.opencontainers.image.ref.name="stable-optimized" \
      stage="final"