#!/bin/sh

set -e

identity='identity.pem'
ipFile='ips.txt'


function restartContainer {
	echo "Processing $ip";
	echo "Command: ssh -i $identity ubuntu@$ip 'sudo docker stop \$(sudo docker ps -q)'";
	ssh -i ${identity} ubuntu@$ip 'sudo docker stop $(sudo docker ps -q)' 2>&1 > /dev/null || true;
	sleep 2;
	echo "Command: ssh -i $identity ubuntu@$ip 'sudo docker run -it -d --rm alpine/bombardier -c 850 -d 3600s -l ${target}'";
	ssh -i ${identity} ubuntu@$ip "sudo docker run -it -d --rm alpine/bombardier -c 850 -d 3600s -l ${target}";
	echo 'Done';
}


while getopts ":i:p:t:" opt; do
  case $opt in
    i) identity="$OPTARG"
    ;;
    p) ipFile="$OPTARG"
    ;;
    t) target="$OPTARG"
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


# Check target url.
if [ -z "$target" ]
then
	echo "ERROR: Target resource is not provided"
	exit
fi

echo "Target resource: $target"


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
	restartContainer "$ip"
done 10< "$ipFile"
