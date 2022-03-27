# Docker for Pentesters

![Nightingale Logo](https://raw.githubusercontent.com/OWASP/www-project-nightingale/main/assets/images/Nightingale.png)

[![OWASP Flagship](https://img.shields.io/badge/owasp-flagship%20project-48A646.svg)](https://www.owasp.org/index.php/Category:OWASP_Project#tab=Project_Inventory)<br>

![](https://img.shields.io/github/followers/RAJANAGORI?style=social)<br>
![](https://img.shields.io/github/stars/RAJANAGORI?style=social)<br>
[![](https://img.shields.io/badge/-Follow-black?style=social&logo=Linkedin)](https://www.linkedin.com/in/raja-nagori/) [![](https://img.shields.io/twitter/follow/RajaNagori7?style=social&label=Follow)](https://twitter.com/RajaNagori7)
[![Medium Badge](https://img.shields.io/badge/-@rajanagori-03a57a?style=flat-square&labelColor=000000&logo=Medium&link=https://medium.com/@rajanagori)](https://medium.com/@rajanagori)

## Project Name: Nightingale
==================================================
## Docker for Pentesters: Pentesting Framework 

## Description
Docker containerization is most powerful technologies in the current market so I came with the idea to develop Docker images for Pentesters.

Nightingale contain all the required well-known tools that will be required to the Pentesters at the time of Penetration Testing. This docker image has a base support of Debian and it is completely platform Independent.

You can either create a docker image in your local host machine by modifying according to your requirements or you can directly pull the docker image from the docker hub itself.

### Why? 
The Reason behind creating this Docker file to make a platform independent penetration toolkit. It Include all the usefull tools that will be required to a penetration tester
(You can refer to the tool list section for same).
## Docker Image build and Run 
- Take a clone of the repository
```
$ git clone --depth 1 https://github.com/RAJANAGORI/Nightingale.git
```
- Change the Directory
```
$ cd Nightingale
```
- Now build the Docker Image.
```
$ docker build -t rajanagori/nightingale .
```
- After Creating the Docker Image, Login into the image and Happy Hacking.... ;-)
```
$ docker run -ti --hostname nightingale  rajanagori/nightingale /bin/bash
```
- Now, you can directly access Nightingale interactive terminal using browser
```
$ docker run -it -p 0.0.0.0:8080:7681 -d rajanagori/nightingale /home/binaries/ttyd -p 7681 bash
```
- If you want to run MobSF along with the nigtingale then I will give you a good new now you can do the same....!!
#### part 1
```
$ docker run -it -p 0.0.0.0:8080:7681 -p 0.0.0.0:8081:8081 -d rajanagori/nightingale /home/binaries/ttyd -p 7681 bash
```
#### part 2
```
cd /home/tools_mobile_vapt/Mobile-Security-Framework-MobSF/
source venv/bin/activate
./run 0.0.0.0:8081 &
```
- Call your browser and hit 127.0.0.1:8080 for nightingale terminal and 127.0.0.1:8081 for MobFs to become you will be prooo!!!!

### For Localtunnel
- Hit 127.0.0.1:8080 in your browser and you will be able to access the Nightingale terminal
- Now, run the following command in your terminal
```
nvm install v16.14.0 && npm install -g localtunnel
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

Please feel free to contribute in the tool


If you want to appreciate my work than you can buy me a coffe :)<br><br>
<a href="https://www.buymeacoffee.com/rajanagori"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a burger&emoji=🍔&slug=rajanagori&button_colour=5F7FFF&font_colour=ffffff&font_family=Lato&outline_colour=000000&coffee_colour=FFDD00" /></a>
