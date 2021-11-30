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
docker build -t rajanagori/nightingale .
```
- After Creating the Docker Image, Login into the image and Happy Hacking.... ;-)
```
 docker run -ti --hostname nightingale  rajanagori/nightingale /bin/bash
```
- Now, you can directly access Nightingale interactive terminal using browser
```
docker run -it -p 0.0.0.0:8080:7681 -d rajanagori/nightingale /home/tool-for-pentester/binary/ttyd -p 7681 bash
```
- Now call your browser and hit 127.0.0.1:8080 and you will be prooo!!!!


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
- https://github.com/phocean/dockerfile-msf.gitY
- https://github.com/c0dejump/HawkScan.git
- https://github.com/1N3/Sn1per.git
- https://github.com/tomnomnom
- https://github.com/s0md3v/XSStrike
- https://github.com/tomnomnom/httprobe.git



Please feel free to contribute

<a href="https://www.buymeacoffee.com/rajanagori"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=🍵&slug=rajanagori&button_colour=5F7FFF&font_colour=ffffff&font_family=Arial&outline_colour=000000&coffee_colour=FFDD00"></a>

