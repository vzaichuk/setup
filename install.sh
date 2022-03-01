#!/bin/bash

identity='identity.pem'

while getopts ":i:p:" opt; do
  case $opt in
    i) identity="$OPTARG"
    ;;
    p) ip="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done


# Check identity file.
if [ -z "$identity" ]
then
  echo "ERROR: Path to pem file is not provided"
  exit
fi

if [ ! -f $identity ]
then
  echo "ERROR: Identity file '$identity' doesn't exists."
  exit
fi

echo "Path to identity pem file: $identity"


# Check ip file.
if [ -z $ip ]
then
  echo "ERROR: IP address is not specified."
  exit
fi

echo "Server ip: $ip"


# Copy.
if [ ! $(ssh -i ${identity} ubuntu@${ip} 'command -v docker') ]
then
  echo "Installing docker..." &&
  ssh -i ${identity} ubuntu@${ip} './setup.sh' &&
  echo "Done"
else
  echo "Docker is already installed"
fi
