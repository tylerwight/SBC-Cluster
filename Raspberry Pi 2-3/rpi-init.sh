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
read hostname
echo "setting hostname to $hostname"
sudo echo "$hostname" > /etc/hostname
sudo sed -i s/raspberrypi/$hostname/g /etc/hosts
hostnamectl set-hostname '$hostname'

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

# these commands may break if the get.docker.com script changes these lines, should be easy enough to find an update though.
#These commands just comment out 2 lines that install docker. This way the script only adds the repositories,
#so we can choose to install a specific version
sed -i -e 's/$sh_c "$pkg_manager install -y -q docker-ce/#$sh_c "$pkg_manager install -y -q docker-ce/g' get_docker.sh
sed -i -e 's/$sh_c "apt-get install -y -qq --no-install-recommends docker-ce/#$sh_c "apt-get install -y -qq --no-install-recommends docker-ce/g' get_docker.sh
sh get_docker.sh
sudo apt-cache madison docker-ce
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~raspbian


# Add repo list and install kubeadm. At the time of writing I'm installing 1.12.3-00
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
sudo apt-get update -q && \
#change this to install specific version of kubeadm
sudo apt-get install -qy kubeadm

echo -e '\n\n'
echo '===================='
echo 'Finished, here is some output to check MOST things have been installed'
echo 'cat /etc/hostname: '
cat /etc/hostname
echo 'packages:'
dpkg -l docker*
dpkg -l kube*
echo "contents of rc.local:"

sudo apt-cache madison docker-ce
sudo apt-cache madison kubeadm
