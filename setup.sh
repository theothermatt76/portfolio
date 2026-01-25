#!/bin/bash
#Set up a new bug bounty program!
if [[ -z "$1" ]]; then
    echo "Error: Invalid target! Usage: ./setup.sh <DOMAIN>"
    exit 1
else
    echo "Setting up environment for $1"
DOMAIN=$1
mkdir $DOMAIN
#Somewhere to put your recon output.
mkdir $DOMAIN/recon
#Organize your notes.
mkdir $DOMAIN/notes
echo "##This is a blank scratch pad. Use it for notes to yourself, weird finds you want to look at later, credentials discovered, etc.##" > $DOMAIN/notes/scratchpad.txt
#A place for screenshots, files, binaries...
mkdir $DOMAIN/artifacts
#Put it all together and keep it here.
mkdir $DOMAIN/report
echo "Setup complete! You can now access your environment at ./$DOMAIN"
echo "Happy hacking!"
fi
