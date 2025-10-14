###############################################################################
# Nightingale Mobile VAPT Tools Image
# Description: Docker image with mobile application security testing tools
# Author: Raja Nagori <raja.nagori@owasp.org>
# License: GPL-3.0
###############################################################################

# Base image with programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable-optimized

# Metadata labels following OCI standards
LABEL org.opencontainers.image.title="Nightingale Mobile VAPT" \
      org.opencontainers.image.description="Mobile application security testing tools for Nightingale" \
      org.opencontainers.image.authors="Raja Nagori <raja.nagori@owasp.org>" \
      org.opencontainers.image.licenses="GPL-3.0 license" \
      org.opencontainers.image.url="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.source="https://github.com/RAJANAGORI/Nightingale" \
      org.opencontainers.image.version="2.0.0" \
      stage="mobile-vapt"

# Build argument
ARG DEBIAN_FRONTEND=noninteractive

# Copy necessary scripts and configurations
COPY --chmod=755 configuration/nodejs-env/node-installation-script.sh /temp/node-installation-script.sh
COPY --chmod=755 configuration/modules-installation/rms-install-modules.sh /temp/rms-install-module.sh
COPY configuration/nodejs-pm2-configuration/pm2-rms.json /temp/pm2-rms.json

# Install system dependencies and setup Node.js
# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        git \
        make \
        cmake \
        bundler \
        dos2unix \
        pipx; \
    # Install Node.js
    bash /temp/node-installation-script.sh || echo "Warning: Node.js installation encountered issues"; \
    # Create directory for mobile VAPT tools
    mkdir -p /home/tools_mobile_vapt; \
    # Verify directory
    test -d /home/tools_mobile_vapt || exit 1; \
    # Cleanup
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Set environment variable
ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/

# Set working directory for mobile VAPT tools
WORKDIR ${TOOLS_MOBILE_VAPT}

# Clone mobile security tools
RUN set -eux; \
    echo "Cloning mobile security tools..."; \
    # Clone MobSF (Mobile Security Framework)
    git clone --depth 1 https://github.com/MobSF/Mobile-Security-Framework-MobSF.git; \
    # Clone RMS (Runtime Mobile Security)
    git clone --depth 1 https://github.com/m0bilesecurity/RMS-Runtime-Mobile-Security.git rms; \
    # Remove .git folders to save space
    rm -rf Mobile-Security-Framework-MobSF/.git rms/.git; \
    # Verify cloning
    test -d Mobile-Security-Framework-MobSF || exit 1; \
    test -d rms || exit 1; \
    echo "Mobile security tools cloned successfully"

# Copy PM2 configuration for RMS
COPY configuration/nodejs-pm2-configuration/pm2-rms.json rms/pm2-rms.json

# Install MobSF
RUN set -eux; \
    echo "Installing MobSF..."; \
    cd Mobile-Security-Framework-MobSF; \
    # Make setup script executable
    chmod +x setup.sh; \
    # Create virtual environment
    python3 -m venv venv; \
    # Run setup script
    if [ -x setup.sh ]; then \
        bash -c "source venv/bin/activate && ./setup.sh" || echo "Warning: MobSF setup encountered issues"; \
    fi; \
    cd ..; \
    echo "MobSF installation completed"

# Install RMS (Runtime Mobile Security)
RUN set -eux; \
    echo "Installing RMS..."; \
    # Make script executable
    chmod +x /temp/rms-install-module.sh; \
    # Convert line endings
    dos2unix /temp/rms-install-module.sh 2>/dev/null || true; \
    # Run installation script
    /temp/rms-install-module.sh || echo "Warning: RMS installation encountered issues"; \
    echo "RMS installation completed"

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
        /root/.npm/*; \
    # Add tools to PATH
    if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then \
        echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc; \
    fi; \
    if ! grep -q 'TOOLS_MOBILE_VAPT' ~/.bashrc 2>/dev/null; then \
        echo 'export TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/' >> ~/.bashrc; \
    fi; \
    echo "Mobile VAPT tools setup complete"

# Set final working directory
WORKDIR /home

# Expose ports for MobSF and RMS
# 8000: MobSF web interface
# 8001: RMS server
EXPOSE 8000 8001

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD test -d /home/tools_mobile_vapt/Mobile-Security-Framework-MobSF || exit 1

# Default command
CMD ["/bin/bash"]

###############################################################################
# Included Tools:
# - MobSF: Mobile Security Framework for Android/iOS security assessment
# - RMS: Runtime Mobile Security for dynamic instrumentation
#
# Usage:
# docker build -f Dockerfiles/mobile_vapt.Dockerfile \
#   -t nightingale_mobile_vapt_image:stable-optimized .
#
# Start MobSF:
# cd ${TOOLS_MOBILE_VAPT}/Mobile-Security-Framework-MobSF
# source venv/bin/activate
# ./run.sh
#
# Start RMS:
# cd ${TOOLS_MOBILE_VAPT}/rms
# npm start
###############################################################################
