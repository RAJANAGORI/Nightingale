#!/bin/bash
git clone --depth 1 https://github.com/nvm-sh/nvm.git /root/.nvm && \
chmod -R 777 /root/.nvm/ && \
bash /root/.nvm/install.sh && \
bash -i -c 'nvm install v16.14.0';
bash -i -c 'npm install -g pm2 localtunnel';