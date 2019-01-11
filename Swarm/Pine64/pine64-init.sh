#!/bin/bash
#This script will get a Pine64 ready to execute kubeadm init/join. Using img "xenial-minimal-pine64-bspkernel-0.7.9-104.img"
#All devices have static DHCP leases, so no static IPs are set. Get ssh access and run this as root.

if [ `whoami` != 'root' ]
  then
    echo "You must be root to do this."
    exit
fi

#set hostname
echo "What hostname do you want to use?"
read myhostname
echo "setting hostname to $myhostname"
echo "$myhostname" > /etc/hostname
sed -i s/pine64/$myhostname/g /etc/hosts
hostnamectl set-hostname "$myhostname"
sudo hostname "$myhostname"


sudo apt-get update
curl -sSL get.docker.com > get_docker.sh
sh get_docker.sh
sudo apt-get install -y docker-ce
sudo apt-get update


echo -e '\n\n'
echo '===================='
echo 'Finished, here is some output to check some of the changes'
echo 'cat /etc/hostname: '
cat /etc/hostname
echo 'packages:'
dpkg -l docker*
echo "contents of rc.local:"
sudo apt-cache madison docker-ce
