#!/bin/bash

## Run me first!

apt install reprepro apache2 simple-cdd lftp
cp conf/000-default.conf /etc/apache2/sites-available
systemctl restart apache2

gpg --homedir /home/harbian-build/.gnupg/ --armor --output cert.gpg --export citypw@hardenedlinux.org
apt-key add cert.gpg
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/harbian-archive.gpg

cp /usr/share/simple-cdd/profiles/default.preseed /usr/share/simple-cdd/profiles/default.preseed.bak

echo "d-i preseed/early_command string anna-install simple-cdd-profiles" > /usr/share/simple-cdd/profiles/default.preseed
