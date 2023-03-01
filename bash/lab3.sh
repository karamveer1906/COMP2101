#!/bin/bash

# Install LXD if necessary
if ! [ -x "$(command -v lxd)" ]; then
echo "Installing LXD"
sudo apt-get update
sudo snap install lxd
 else
echo "LXD tools already installed"
fi

# Initialize LXD if no lxdbr0 interface exists
if ! ip a show lxdbr0; then
echo "lxdbr0 interface does not exist"
# Initialize LXD with --auto flag
sudo lxd init --auto
else
echo "LXDBR interface exist"
fi

# Launch container if necessary
if ! lxc info COMP2101-S22; then
echo "Container does not exist"
# Launch a new container running Ubuntu 20.04 server
lxc launch images:ubuntu/20.04 COMP2101-S22
else 
echo "Container already exists"
fi
# Add/update /etc/hosts entry for COMP2101-S22
if grep -q "COMP2101-S22" /etc/hosts; then
echo "Host Entry is already updated"
else
echo "$IP COMP2101-S22" | sudo gedit /etc/hosts
fi

# Install Apache2 if necessary
if ! lxc exec COMP2101-S22 -- systemctl status apache2 > /dev/null; then
  lxc exec COMP2101-S22 -- apt-get update
  lxc exec COMP2101-S22 -- apt-get install -y apache2
else
echo "Apache2 is already installed"
fi

# Test  the default page
if [ "curl http://COMP2101-S22 >/dev/null 2>&1" ];then
      echo "the default web page is successfully retrieved"
else
      echo "error exists default web page is not able to retrieve"
fi




