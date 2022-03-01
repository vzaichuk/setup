#!/bin/bash

identity='identity.pem'
ipFile='ips.txt'

while getopts ":i:p:" opt; do
  case $opt in
    i) identity="$OPTARG"
    ;;
    p) ipFile="$OPTARG"
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
if [ ! -f $ipFile ]
then
    echo "ERROR: IP file '$ipFile' doesn't exists."
    exit
fi

echo "Using ip file: $ipFile"


# Copy.
echo "Stopping containers..."
while IFS= read -u10 -r ip
do
  echo "Delivering to ${ip}";
  scp -i ${identity} setup.sh nakhuy.sh stop.sh ubuntu@${ip}:/home/ubuntu &&
  ssh -i ${identity} ubuntu@${ip} 'chmod +x setup.sh stop.sh nakhuy.sh' &&
  ./install.sh -p $ip &&
  echo "Done";
done 10< "$ipFile"
