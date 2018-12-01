#!/bin/bash
#This script will get a Pine64 ready to execute kubeadm init/join. Using img "xenial-minimal-pine64-bspkernel-0.7.9-104.img"
#All devices have static DHCP leases, so no static IPs are set. Get ssh access and run this
#run as root

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

#You can set static IPs be editing the file /etc/network/interfaces.d/eth0
#you may also need these:
# sudo systemctl stop NetworkManager.service
# sudo systemctl disable NetworkManager.service
#

#remove swap, and make it persistent on boot
sudo swapoff -a
sudo sed -i '/exit 0/i \swapoff -a' /etc/rc.local

sudo apt-get update

#download install script into get_docker.sh
curl -sSL get.docker.com > get_docker.sh

# these commands may break if the get.docker.com script changes these lines, should be easy enough to find an update though.
#These commands just comment out 2 lines that install docker. This way the script only adds the repositories,
#so we can choose to install a specific version
sed -i -e 's/$sh_c "$pkg_manager install -y -q docker-ce/#$sh_c "$pkg_manager install -y -q docker-ce/g' get_docker.sh
sed -i -e 's/$sh_c "apt-get install -y -qq --no-install-recommends docker-ce/#$sh_c "apt-get install -y -qq --no-install-recommends docker-ce/g' get_docker.sh
sh get_docker.sh
sudo apt-cache madison docker-ce
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu

#add gpg key, add repo to apt sources
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

#install kubelet, kubeadm, kubectl. At time of writing, I am installing 1.12.3-00

sudo apt-get update
#Change these to install specific verison
sudo apt-get install -y kubelet kubeadm kubectl

echo -e '\n\n'
echo '===================='
echo 'Finished, here is some output to check MOST things have been installed'
echo 'cat /etc/hostname: '
cat /etc/hostname
echo 'packages:'
dpkg -l docker*
dpkg -l kube*
echo "contents of rc.local:"
tail -n 5 /etc/rc.loal
sudo apt-cache madison docker-ce
sudo apt-cache madison kubeadm
