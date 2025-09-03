## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:arm64
ARG DEBIAN_FRONTEND=noninteractive

COPY configuration/nodejs-env/node-installation-script.sh /temp
COPY configuration/modules-installation/rms-install-modules.sh /temp/rms-install-modules.sh
COPY configuration/nodejs-pm2-configuration/pm2-rms.json /temp/pm2-rms.json

# Update and install necessary tools
RUN apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    pipx \
    python3-pip \
    dos2unix && \
    bash /temp/node-installation-script.sh && \
    mkdir -p /home/tools_mobile_vapt

ENV TOOLS_MOBILE_VAPT=/home/tools_mobile_vapt/

# All Mobile (Android and iOS) VAPT support
WORKDIR ${TOOLS_MOBILE_VAPT}

# Install MobSF and RMS
RUN git clone --depth 1 https://github.com/MobSF/Mobile-Security-Framework-MobSF.git && \
    git clone --depth 1 https://github.com/m0bilesecurity/RMS-Runtime-Mobile-Security.git rms

# Copy PM2 configuration for RMS
COPY configuration/nodejs-pm2-configuration/pm2-rms.json rms/pm2-rms.json
# Copy necessary scripts and configurations

# Install MobSF
RUN cd Mobile-Security-Framework-MobSF && \
    python3 -m venv venv && \
    ./setup.sh && \
    cd ..

# Install RMS-Runtime-Mobile-Security
RUN chmod +x /temp/rms-install-modules.sh 
# && \
#     dos2unix /temp/rms-install-modules.sh && \
#     /temp/rms-install-modules.sh

# Clean up unnecessary files and libraries
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* && \
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

# Set final working directory
WORKDIR /home