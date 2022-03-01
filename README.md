### Configure ip addresses of server instances
Add all IP addresses to `ips.txt`. Leave one empty line in end of file, otherwise last ip address won't be read.

### Place identity pem file
Place identity file to directory with scripts and name it as `identity.pem` or use parameter `-i <path-to-identity-file>` during scripts run.

### Setup environment
```bash
chmod +x deliver.sh nakhuy.sh stop.sh
./deliver.sh
```

### Run
```bash
./nakhuy.sh -t <url> [-i <path-to-pem-file>] [-p <path-to-ips-file>]
```

