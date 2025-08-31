## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:stable
# Update and install necessary tools
RUN apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    pipx && \
    # Create directories for tools
    mkdir -p /home/tools_red_teaming /home/tools_forensics

# Set environment variables
ENV TOOLS_RED_TEAMING=/home/tools_red_teaming \
    TOOLS_FORENSICS=/home/tools_forensics

# Install Impact toolkit for Red-Team
WORKDIR ${TOOLS_RED_TEAMING}
RUN python3 -m pipx install impacket && \
    pipx ensurepath

# Clean up unnecessary files and libraries
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* && \
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home