#!/bin/bash
echo "My second script"
#dat1 is a variable which will give the hostname
dat1=$(hostname)
#dat2 is a variable which will give the fully qualified domain name(FQDN)
dat2=$(hostname -f)
#dat 3 will give the whole information regarding the system and grep will trim it operating system information
dat3=$(hostnamectl | grep Operating)
#dat4  is a variable which will provide the IP address of the host name
dat4=$(hostname -I)
#dat5 is a variable which will give us the system indormation in which awk is used to give only the fourth line and then tail is used because we only want the last line
dat5=$(df -h / | awk '{print $4}' | tail -n 1)
cat <<EOF
Report for:$dat1
===============
FQDN:$dat2
Operating System name and version:$dat3
IP Address:$dat4
Root Filesystem Free Space:$dat5
===============
EOF

