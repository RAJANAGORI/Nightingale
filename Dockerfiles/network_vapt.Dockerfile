## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable
ARG DEBIAN_FRONTEND=noninteractive

# Update and install necessary tools
RUN apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    pipx && \
    # Create directories for tools
    mkdir -p /home/tools_network_vapt

ENV TOOLS_NETWORK_VAPT=/home/tools_network_vapt

# Set working directory
WORKDIR ${TOOLS_NETWORK_VAPT}

# Clone tools repository
RUN git clone --depth 1 https://github.com/sullo/nikto.git && \
    # Clean up unnecessary files and libraries
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* && \
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home