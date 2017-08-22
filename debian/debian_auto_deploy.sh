#!/bin/bash

WORKDIR=/tmp/debian-grsec-configs
mkdir -p $WORKDIR
cd $WORKDIR

echo "###########################################################################"
echo -e "[+] \e[93mInstalling paxctl-ng/elfix...\e[0m"
echo "----------------------------------------------"
sudo apt-get install -y vim libc6-dev libelf-dev libattr1-dev build-essential
wget https://dev.gentoo.org/%7Eblueness/elfix/elfix-0.9.2.tar.gz && tar zxvf elfix-0.9.2.tar.gz
cd elfix-0.9.2
./configure --enable-ptpax --enable-xtpax --disable-tests
make && sudo make install
cd $WORKDIR

echo "###########################################################################"
echo -e "[+] \e[93mDeploying configs....\e[0m"
echo "----------------------------------------------"

wget https://github.com/hardenedlinux/hardenedlinux_profiles/raw/master/debian/77pax-bites
wget https://github.com/hardenedlinux/hardenedlinux_profiles/raw/master/debian/pax_flags_debian.config

sudo cp 77pax-bites /etc/apt/apt.conf.d/
sudo cp pax_flags_debian.config /etc/

echo "###########################################################################"
echo -e "[+] \e[93mDeploying pax-bites...\e[0m"
echo "----------------------------------------------"
git clone https://github.com/hardenedlinux/pax-bites.git
sudo cp pax-bites/pax-bites.sh  /usr/sbin/
sudo pax-bites.sh -e /etc/pax_flags_debian.config
