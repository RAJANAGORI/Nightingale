    #!/bin/bash
    cd ${TOOLS_MOBILE_VAPT}/rms  
    bash -i -c 'npm install';
    bash -i -c 'pm2 start pm2-rms.json';