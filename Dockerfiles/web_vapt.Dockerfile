## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:development

## Installing tools using apt-get for web vapt
RUN apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    unzip && \
    rm -rf /var/lib/apt/lists/*

### Creating Directories
RUN mkdir -p /home/tools_web_vapt /home/.gf

### Creating Directories
ENV TOOLS_WEB_VAPT=/home/tools_web_vapt/
ENV GREP_PATTERNS=/home/.gf/

WORKDIR ${GREP_PATTERNS}

RUN git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git ${GREP_PATTERNS}

WORKDIR ${TOOLS_WEB_VAPT}

# git clonning of tools repository
RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git && \
    git clone --depth 1 https://github.com/c0dejump/HawkScan.git && \
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git && \
    git clone --depth 1  https://github.com/maurosoria/dirsearch.git && \
    git clone --depth 1  https://github.com/s0md3v/Arjun.git && \
    git clone --depth 1 https://github.com/blechschmidt/massdns.git && \
    git clone --depth 1 https://github.com/s0md3v/Striker.git && \
    git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git && \
    git clone --depth 1 https://github.com/aboul3la/Sublist3r.git && \
    git clone --depth 1 https://github.com/ticarpi/jwt_tool.git && \
    git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git

# Installing Tools

# # Installing Arjun
# RUN cd Arjun && \
#     python3 setup.py install && \
#     cd ..

# ## Installing HawkScan
# RUN cd HawkScan && \
#     sed -i 's/^python-whois$/python-whois==0.7.3/' requirements.txt &&\
#     python3 setup.py install && \
#     pip3 install -r requirements.txt && \
#     python3 -m pip install -r requirements.txt &&\
#     cd ..

# # Installing LinkFinder
# RUN cd LinkFinder && \
#     python3 setup.py install &&\
#     cd ..

# ## Installing Striker
# RUN cd Striker && \
#     pip3 install -r requirements.txt &&\
#     cd ..

# ## Installing dirsearch
# RUN cd dirsearch && \
#     python3 setup.py install && \
#     cd ..

# ## Installing jwt_tool
# RUN cd jwt_tool && \
#     pip3 install -r requirements.txt &&\
#     cd ..

# ## Installing Sublist3r
# RUN cd Sublist3r && \
#     python3 setup.py install &&\
#     cd ..

# ## Installing XSStrike
# RUN cd XSStrike && \
#     pip3 install -r requirements.txt &&\
#     cd ..

# # Installing WhatWeb
# RUN cd WhatWeb && \
#     make install && \
#     cd ..

## Installing Amass
RUN wget --quiet https://github.com/OWASP/Amass/releases/download/v3.16.0/amass_linux_amd64.zip -O amass.zip && \
    unzip amass.zip && \
    mv amass_linux_amd64/amass /usr/local/bin && rm -rf amass_linux_amd64 amass.zip

### Cleaning Unwanted libraries
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home