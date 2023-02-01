#!/bin/bash
echo "My second script"
#hostname represents the domain name of my virtual pc
echo "Domain Name"
hostname
#hostenamectl will give all the  required information regarding linux like version and all
echo "Host Information:"
hostnamectl
#hostename -I will tell us the Ip address of host
echo "IP Addresses:"
hostname -I
#df will give us the data regarding the amount of space available in root filesystem
echo "Root Filesystem Status"
df
