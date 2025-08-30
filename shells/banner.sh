#!/bin/bash

# Print the "Nightingale" banner
figlet Nightingale

figlet -f term "Made by Raja Nagori <3 from India"

# Set up aliases for ping and ping6
alias ping="ping -4"
alias ping6="ping -6"
alias recon-ng="cd ${TOOLS_OSINT}/recon-ng && source ./recon-ng/bin/activate && ./recon-ng"