# Stage 1: Building the image
FROM rajanagori/nightingale_programming_image:v1 AS builder

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"

ARG DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get -y update --fix-missing && \
    apt-get -f --no-install-recommends install -y \
    software-properties-common \
    ca-certificates \
    build-essential

# Stage 2: Install OS tools and dependencies
FROM builder AS os-tools

RUN apt-get -y update && \
    apt-get -f --no-install-recommends install -y \
    locate \
    snapd \
    tree \
    zsh \
    figlet \
    unzip \
    p7zip-full \
    ftp \
    ssh \
    git \
    curl \
    wget \
    file \
    dirb \
    nmap \
    htop \
    traceroute \
    telnet \
    net-tools \
    iputils-ping \
    tcpdump \
    openvpn \
    whois \
    host \
    tor \
    john \
    cewl \
    hydra \
    medusa \
    figlet \
    dnsutils \
    android-framework-res \
    adb \
    apktool \
    exiftool \
    steghide \
    binwalk \
    foremost \
    dos2unix \
    libnss-ldap \
    libpam-ldap \
    ldap-utils \
    nscd

# Stage 3: Set up shell and environment
FROM builder AS shell

# Copy necessary scripts
COPY shells/banner.sh /tmp/banner.sh
COPY shells/node-installation-script.sh /temp/node-installation-script.sh

# Set up zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN cat /tmp/banner.sh >> ${HOME}/.bashrc && \
    cat /tmp/banner.sh >> ${HOME}/.zshrc && \
    dos2unix ${HOME}/.bashrc && \
    dos2unix ${HOME}/.zshrc && \
    dos2unix /temp/node-installation-script.sh && \
    chmod +x /temp/node-installation-script.sh

# Stage 4: Copy directories and files
FROM builder AS directories

# Create necessary directories
RUN mkdir -p /home/tools_web_vapt /home/binaries /home/.gf /home/tools_osint /home/tools_mobile_vapt \
    /home/tools_network_vapt /home/tools_red_teaming /home/tools_forensics /home/wordlist /home/.shells

# Copy directories from other images
COPY --from=rajanagori/nightingale_web_vapt_image:v1.0 /home/tools_web_vapt /home/tools_web_vapt
COPY --from=rajanagori/nightingale_web_vapt_image:v1.0 /home/.gf /home/.gf
COPY --from=rajanagori/nightingale_osint_image:v1.1 /home/tools_osint /home/tools_osint
COPY --from=rajanagori/nightingale_mobile_vapt_image:v1.0 /home/tools_mobile_vapt /home/tools_mobile_vapt
COPY --from=rajanagori/nightingale_network_vapt_image:v1.0 /home/tools_network_vapt /home/tools_network_vapt
COPY --from=rajanagori/nightingale_forensic_and_red_teaming:v1.0 /home/tools_red_teaming /home/tools_red_teaming
COPY --from=rajanagori/nightingale_forensic_and_red_teaming:v1.0 /home/tools_forensics /home/tools_forensics
COPY --from=rajanagori/nightingale_wordlist_image:v1.0 /home/wordlist /home/wordlist

# Stage 5: Install scripts and binaries
FROM builder AS scripts-binaries

# Copy scripts and run them
COPY configuration/modules-installation/python-install-modules.sh /home/.shells/python-install-modules.sh
RUN dos2unix /home/.shells/python-install-modules.sh && chmod +x /home/.shells/python-install-modules.sh
RUN /home/.shells/python-install-modules.sh && /temp/node-installation-script.sh

# Copy and install binaries
WORKDIR /home/binaries
COPY binary/ /home/binaries
RUN chmod +x /home/binaries/* && \
    dos2unix * && \
    mv /home/binaries/* /usr/local/bin/ && \
    wget -L https://github.com/RAJANAGORI/Nightingale/blob/main/binary/ttyd -O ttyd && \
    chmod +x ttyd

# Stage 6: Install Metasploit
FROM builder AS metasploit

WORKDIR /home/metasploit

# Copy Metasploit files
COPY configuration/msf-configuration/scripts/db.sql .
COPY configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh
COPY ./configuration/msf-configuration/conf/database.yml /home/msfuser/.msf4/database.yml

# Install Metasploit framework
RUN curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall

# Stage 7: Final Image
FROM rajanagori/nightingale_programming_image:v1

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"

# Copy necessary files and directories from each stage
COPY --from=os-tools /usr/bin/ /usr/bin/
COPY --from=shell /root/ /root/
COPY --from=directories /home/ /home/
COPY --from=scripts-binaries /usr/local/bin/ /usr/local/bin/
COPY --from=scripts-binaries /usr/local/rvm/ /usr/local/rvm/
COPY --from=metasploit /home/metasploit/ /home/metasploit/

# Expose the service ports
EXPOSE 5432
EXPOSE 8080
EXPOSE 8081
EXPOSE 7681
EXPOSE 8083

# Clean up unnecessary libraries
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*
