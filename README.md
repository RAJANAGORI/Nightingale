# Docker for Pentesters

![Nightingale Logo](https://raw.githubusercontent.com/OWASP/www-project-nightingale/main/assets/images/Nightingale.png)

[![OWASP Incubator](https://img.shields.io/badge/owasp-incubator-blue.svg)](https://www.owasp.org/index.php/Category:OWASP_Project#tab=Project_Inventory)

![BlackHat Asia 2022](https://raw.githubusercontent.com/RAJANAGORI/Nightingale/main/assets/images/blackhat_2022.svg)
![OWASP AppSec EU 2022 2022](https://raw.githubusercontent.com/RAJANAGORI/Nightingale/main/assets/images/Owasp_Global_Appsec_EU.svg)
[![OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/projects/6871/badge)](https://bestpractices.coreinfrastructure.org/projects/6871)

![](https://img.shields.io/github/followers/RAJANAGORI?style=social)
![](https://img.shields.io/github/stars/RAJANAGORI?style=social)
[![](https://img.shields.io/badge/-Follow-black?style=social&logo=Linkedin)](https://www.linkedin.com/in/raja-nagori/) [![](https://img.shields.io/twitter/follow/RajaNagori7?style=social&label=Follow)](https://twitter.com/RajaNagori7)
![profile count](https://komarev.com/ghpvc/?username=www-project-nightingale&color=blue)
[![Medium Badge](https://img.shields.io/badge/-@rajanagori-03a57a?style=flat-square&labelColor=000000&logo=Medium&link=https://medium.com/@rajanagori)](https://medium.com/@rajanagori)

### To run the Nightingale with OPENLdap, use the below command
```
docker-compose up -d
```
### Conferences
- Blackhat Arsenal ASIA 2022
- OWAPS Global AppSec EU 2022
- Docker community hands on #6
- Blackhat Arsenal MEA 2022 (Shortlisted)
- Blackhat Arsenal ASIA 2023

## Project Name: Nightingale
==================================================
## Docker for Pentesters: Pentesting Framework 

## Description
In today's technological era, docker is the most powerful technology in each and every domain, whether it is Development, cyber security, DevOps, Automation, or Infrastructure.

Considering the demand of the industry, I would like to introduce my idea to create a NIGHTINGALE: docker image for pentesters.

This docker image is ready to use environment will the required tools that are needed at the time of pentesting on any of the scopes, whether it can be web application penetration testing, network penetration testing, mobile, API, OSINT, or Forensics.

The best part is you can either create an altered docker image or pull the pre-built docker image from the hub.

Some of the best features are listed below, I would highly recommend going through it and starting penetrating into the application.
Link to access tool list : [tool list](https://owasp.org/www-project-nightingale/)

### Pros
1.	No need to install multiple programming language support and multiple modules.
2.	Booting process is very fast as per the virtualization concept.
3.	Need as per use resource of the host machine.
4.	All pre-install tools are installed and if you install any new software or tool use can go with that option.
5.	You can perform vulnerability assessment and penetration testing of any scope.
6.	You can access this docker container via browser by calling your local address.

### Cons
1.  You can run the container over cloud server but can’t perform mobile pentesting.
2.  Creating tunnel with SSH can’t help you to provide the connection to your physical device or virtual environment.

Note: Nothing can be impossible, so I will definitely find a solution for the cons points 🤟

### Why? 
The Reason behind creating this Docker file is to make a platform-independent penetration toolkit. It includes all the useful tools that will be required for a penetration tester
(You can refer to the tool list section for the same).

## Architecture Diagram of the NIGHTINGALE.
[Diagram](https://github.com/RAJANAGORI/Nightingale/blob/main/assets/images/architecture.png)

## Docker Image Build and Run 
- Take a clone of the repository
```
git clone --depth 1 https://github.com/RAJANAGORI/Nightingale.git
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
- Now, you can directly access Nightingale interactive terminal using the browser
```
docker run -it -p 0.0.0.0:8080:7681 -d rajanagori/nightingale ttyd -p 7681 bash
```
### If you want to run MobSF along with the nightingale then I will give you good news now you can do the same....!!
#### part 1
```
docker run -it -p 0.0.0.0:8080:7681 -p 0.0.0.0:8081:8081 -d rajanagori/nightingale ttyd -p 7681 bash 
```
#### part 2
```
cd /home/tools_mobile_vapt/Mobile-Security-Framework-MobSF/
source venv/bin/activate
./run 0.0.0.0:8081 &
```
- Call your browser and hit 127.0.0.1:8080 for the nightingale terminal and 127.0.0.1:8081 for MobFs to become you will be prooo!!!!

- If you want to bind your host machine directory to your container directory then you can do the same.
```
docker run -it -p 0.0.0.0:8080:7681 -p 0.0.0.0:8081:8081 -v /<your_host_machine_directory_path>:/<your_container_directory_path> -d rajanagori/nightingale ttyd -p 7681 bash
```

### For Localtunnel
- Hit 127.0.0.1:8080 in your browser and you will be able to access the Nightingale terminal
- Now, run the following command in your terminal
```
lt --port 7681 --subdomain nightingale
```
### To start Runtime Mobile Security Framework
#### part 1
```
docker run -it -p 0.0.0.0:8080:7681 -p 0.0.0.0:8081:8081 -p 0.0.0.0:5000:5000 -d rajanagori/nightingale ttyd -p 7681 bash
```
#### part 2
```
cd tools_mobile_vapt/rms && pm2 start rms.js --name rms
```
Now, hit 127.0.0.1:8080 and have fun with Nightingale !!!
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

Please feel free to contribute to the tool
