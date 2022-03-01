#!/bin/sh

set -e

identity='identity.pem'
ipFile='ips.txt'


function stopContainer {
  echo "Processing $ip";
  echo "Command: ssh -i $identity ubuntu@$ip 'sudo docker stop \$(sudo docker ps -q)'";
  ssh -i ${identity} ubuntu@$ip 'sudo docker stop $(sudo docker ps -q)' 2>&1 > /dev/null || true;
  echo 'Done';
}


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


# Read ip addresses of servers and run containers.
echo "Rerunning containers..."
while IFS= read -u10 -r ip
do
  stopContainer
done 10< "$ipFile"
