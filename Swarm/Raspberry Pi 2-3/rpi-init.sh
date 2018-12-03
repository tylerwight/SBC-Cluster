#!/bin/bash
#This script will get a Raspberry pi 3/2 ready to execute kubeadm init/join. using img '2018-11-13-raspbian-stretch-lite.img'
#All devices have static DHCP leases, so no static IPs are set. Get ssh access and run this

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
sed -i s/raspberrypi/$myhostname/g /etc/hosts
hostnamectl set-hostname "$myhostname"

# Disable Swap
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo update-rc.d dphys-swapfile remove
echo Adding " cgroup_enable=cpuset cgroup_enable=memory" to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt


#static IPs are set in /etc/dhcpcd.conf, I'm using static leases so I don't set these
sudo apt-get update
#download install script into get_docker.sh
curl -sSL get.docker.com > get_docker.sh
sh get_docker.sh
sudo apt-cache madison docker-ce
sudo apt-get install -y docker-ce



sudo apt-get update


echo -e '\n\n'
echo '===================='
echo 'Finished, here is some output to check MOST things have been installed'
echo 'cat /etc/hostname: '
cat /etc/hostname
echo 'packages:'
dpkg -l docker*
dpkg -l kube*

sudo apt-cache madison docker-ce
