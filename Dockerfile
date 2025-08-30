# Stage 1: Base Image with Dependencies
FROM ghcr.io/rajanagori/nightingale_programming_image:stable AS base

LABEL maintainer="Raja Nagori" \
    email="raja.nagori@owasp.org"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates build-essential cmake locate snapd tree zsh figlet unzip p7zip-full ftp ssh git curl wget file nano vim dirb nmap htop traceroute telnet net-tools iputils-ping tcpdump openvpn whois host tor john cewl hydra medusa dnsutils android-framework-res adb apktool exiftool steghide binwalk foremost dos2unix postgresql postgresql-client postgresql-contrib pipx pv hashcat hashcat-data \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Copy Scripts and Configurations
FROM base AS intermediate

COPY shells/banner.sh /tmp/banner.sh
COPY configuration/nodejs-env/ /temp/

RUN dos2unix ${HOME}/.bashrc && \
    cat /tmp/banner.sh >> ${HOME}/.bashrc && \
    mkdir -p /home/tools_web_vapt /home/tools_osint /home/tools_mobile_vapt /home/tools_network_vapt \
    /home/tools_red_teaming /home/tools_forensics /home/wordlist /home/binaries /home/.gf /home/.shells

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

RUN dos2unix ${SHELLS}/python-install-modules.sh \
    && chmod +x ${SHELLS}/python-install-modules.sh \
    && dos2unix ${SHELLS}/go-install-modules.sh \
    && chmod +x ${SHELLS}/go-install-modules.sh \
    && ln -s ${SHELLS}/python-install-modules.sh /usr/local/bin/python-install-modules \
    && ln -s ${SHELLS}/go-install-modules.sh /usr/local/bin/go-install-modules \
    && python-install-modules \
    && go-install-modules

WORKDIR ${BINARIES}
COPY binary/ ${BINARIES}

RUN chmod +x ${BINARIES}/* \
    && mv ${BINARIES}/* /usr/local/bin/ \
    && wget -L https://github.com/tsl0922/ttyd/archive/refs/tags/1.7.7.zip \
    && unzip 1.7.7.zip \
    && cd ttyd-1.7.7 && mkdir build && cd build && cmake .. && make && make install \
    && curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

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

RUN \
    xargs -a /tmp/vuln-library-purge apt-get purge -y --ignore-missing && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* && \
    ln -s ${TOOLS_WEB_VAPT}/hashcat/hashcat /usr/local/bin/hashcat && \
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

WORKDIR /home