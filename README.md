# Docker for Pentesters
## Project Name: Nightingale
==================================================
## Docker for Pentesters: Pentesting Framework 

## Description
This Docker image contain some usefull tools that are highly required for penetration testing and which is platform independent.

### Why? 
The Reason behind creating this Docker file to make a platform independent penetration toolkit. It Include all the usefull tools that will be required to a penetration tester
(You can refer to the tool list section for same).
## Docker Image build and Run 
- Take a clone of the repository
```
git clone https://github.com/RAJANAGORI/Nightingale.git
```
- Change the Directory
```
cd Nightingale
```
- Now build the Docker Image.
```
docker build -t nightingale .
```
- After Creating the Docker Image, Login into the image and Happy Hacking.... ;-)
```
 docker run -ti --hostname nightingale  nightingale /bin/bash
```

## To start, Restart and Stop the Postgresql database 
- To start the service
```
service postgresql start
```
- To Restart the service
```
service postgresql restart
```
- To Stop the service
```
service postgresql stop
```

Note: Use of Postgresql is for msfConsole.
## Refrence 
- https://github.com/phocean/dockerfile-msf.git
- https://github.com/c0dejump/HawkScan.git
- https://github.com/1N3/Sn1per.git
- https://github.com/tomnomnom
- https://github.com/s0md3v/XSStrike
- https://github.com/tomnomnom/httprobe.git



Please free to contribute 


<!-- ## :coffee: Donations

Thanks for your donations, are always appreciated.

While I drink the coffee I check more tools to add in the docker image.

[![Buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/rajanagori) -->
