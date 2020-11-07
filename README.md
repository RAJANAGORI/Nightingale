# Docker for Pentesters
## Project Name: Nightingale
==================================================
## Docker for Pentesters: Pentesting Framework 

## Description
This Docker image contain some usefull tools that are highly required for penetration testing and which is platform independent.

### Why? 
The Reason behind creating this Docker file to make a platform independent penetration toolkit. It Include all the usefull tools that will be required to a penetration tester
(You can refer to the tool list section for same).

## List of tools use in this framework
WpScan : WPScan is an open source WordPress security scanner. You can use it to scan your WordPress website for known vulnerabilities within the WordPress core, as well as popular WordPress plugins and themes.WPScan uses the vulnerability database called wpvulndb.com to check the target for known vulnerabilities.

Sqlmap : sqlmap is an open source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over of database servers.

Dirb : DIRB is a Web Content Scanner. It looks for existing (and/or hidden) Web Objects.

Nmap : Nmap is used to discover hosts and services on a computer network by sending packets and analyzing the responses.

Metasploit Framework : The Metasploit Project is a computer security project that provides information about security vulnerabilities and aids in penetration testing and IDS signature development.

Impacket Toolkit for Red Teamers

HawkScan : Security Tool for Reconnaissance and Information Gathering on a website. (python 2.x & 3.x)

Tor : For Anonymous

Asseset Finder : Find domains and subdomains potentially related to a given domain.

Xsstrike : Most advanced XSS scanner.

Shodan : Shodan is a search engine that lets the user find specific types of computers connected to the internet using a variety of filters.

John the Ripper : It's a Free Password Cracking tool.

more to add

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
docker run -ti nightingale /bin/bash
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



Please free to contribute 
