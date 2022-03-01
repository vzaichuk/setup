#!/bin/sh

set -e

pem=$1
target=$2
ipFileFromParam=$3
ipFile='ips.txt'

function restartContainer {
	echo "Processing $ip";
	echo "Command: ssh -i $pem ubuntu@$ip 'sudo docker stop \$(sudo docker ps -q)'";
	ssh -i ${pem} ubuntu@$ip 'sudo docker stop $(sudo docker ps -q)' 2>&1 > /dev/null || true;
	sleep 2;
	echo "Command: ssh -i $pem ubuntu@$ip 'sudo docker run -it -d --rm alpine/bombardier -c 850 -d 3600s -l ${target}'";
	ssh -i ${pem} ubuntu@$ip "sudo docker run -it -d --rm alpine/bombardier -c 850 -d 3600s -l ${target}";
	echo 'Done';
}


# Check identity file.
if [ -z "$pem" ]
then
	echo "ERROR: Path to pem file is not provided"
	exit
fi

if [ ! -f $pem ]
then
	echo "ERROR: Identity file '$pem' doesn't exists."
	exit
fi

echo "Path to identity pem file: $pem"


# Check target url.
if [ -z "$target" ]
then
	echo "ERROR: Target resource is not provided"
	exit
fi

echo "Target resource: $target"


# Check ip file.
if [ -n "$ipFileFromParam" ]
then
	ipFile=$ipFileFromParam
fi

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
