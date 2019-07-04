#!/bin/bash

WORKDIR=/tmp/mint19-grsec-configs
mkdir -p $WORKDIR
cd $WORKDIR

echo "###########################################################################"
echo -e "[+] \e[93mInstalling paxctl-ng/elfix...\e[0m"
echo "----------------------------------------------"
sudo apt-get install -y vim libc6-dev libelf-dev libattr1-dev git build-essential
wget https://dev.gentoo.org/%7Eblueness/elfix/elfix-0.9.2.tar.gz && tar zxvf elfix-0.9.2.tar.gz
cd elfix-0.9.2
./configure --enable-ptpax --enable-xtpax --disable-tests
make && sudo make install
cd $WORKDIR

echo "###########################################################################"
echo -e "[+] \e[93mDeploying configs....\e[0m"
echo "----------------------------------------------"

wget https://github.com/hardenedlinux/hardenedlinux_profiles/raw/master/linux-mint_desktop/77pax-bites
wget https://github.com/hardenedlinux/hardenedlinux_profiles/raw/master/linux-mint_desktop/pax_flags_mint19.config
wget https://github.com/hardenedlinux/hardenedlinux_profiles/raw/master/linux-mint_desktop/sysctl.conf

sudo cp 77pax-bites /etc/apt/apt.conf.d/
sudo cp pax_flags_mint19.config /etc/
sudo cp sysctl.conf /etc/


echo "###########################################################################"
echo -e "[+] \e[93mDeploying pax-bites...\e[0m"
echo "----------------------------------------------"
git clone https://github.com/hardenedlinux/pax-bites.git
sudo cp pax-bites/pax-bites.sh  /usr/sbin/
sudo pax-bites.sh -e /etc/pax_flags_mint19.config


