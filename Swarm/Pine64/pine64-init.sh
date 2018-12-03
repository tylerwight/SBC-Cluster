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

#You can set static IPs be editing the file /etc/network/interfaces.d/eth0
#you may also need these:
# sudo systemctl stop NetworkManager.service
# sudo systemctl disable NetworkManager.service
#

#remove swap, and make it persistent on boot
sudo swapoff -a
swapoff -a
sudo sed -i '/exit 0/i \swapoff -a' /etc/rc.local
sudo apt-get purge zram-config
sudo apt-get update


curl -sSL get.docker.com > get_docker.sh
sh get_docker.sh
sudo apt-get install -y docker-ce
sudo apt-cache madison docker-ce



#install kubelet, kubeadm, kubectl. At time of writing, I am installing 1.12.3-00

sudo apt-get update


echo -e '\n\n'
echo '===================='
echo 'Finished, here is some output to check MOST things have been installed'
echo 'cat /etc/hostname: '
cat /etc/hostname
echo 'packages:'
dpkg -l docker*
echo "contents of rc.local:"
tail -n 5 /etc/rc.loal
sudo apt-cache madison docker-ce
