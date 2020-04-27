#!/bin/bash

## Make sure you create /data with proper permission if you don't want to run this script as root

BUILD_DIR=/data/mirror/debian
WORK_DIR=`pwd`
REPO_URL='http://deb.debian.org/debian'
HARBIAN_SIGNING_KEY=DA361430B802907E
WEB_IP='144.77.103.7'

cd $BUILD_DIR/dists/buster/main
lftp -c mirror $REPO_URL/dists/buster/main/installer-amd64

cd $BUILD_DIR
wget $REPO_URL/README
wget $REPO_URL/README.CD-manufacture
wget $REPO_URL/README.html
wget $REPO_URL/README.mirrors.html
wget $REPO_URL/README.mirrors.txt

lftp -c mirror $REPO_URL/doc

cd $BUILD_DIR/dists/buster
MD5=$(md5sum main/installer-amd64/current/images/SHA256SUMS | awk  '{print $1}' )
SHA1=$(sha1sum main/installer-amd64/current/images/SHA256SUMS | awk  '{print $1}' )
SHA256=$(sha256sum main/installer-amd64/current/images/SHA256SUMS | awk  '{print $1}' )
SIZE=$(ls -al main/installer-amd64/current/images/SHA256SUMS  | awk '{print $5}')
sed -i "/MD5Sum:/a \ $MD5 $SIZE main/installer-amd64/current/images/SHA256SUMS"  Release
sed -i "/SHA1:/a \ $SHA1 $SIZE main/installer-amd64/current/images/SHA256SUMS" Release
sed -i "/SHA256:/a \ $SHA256 $SIZE main/installer-amd64/current/images/SHA256SUMS" Release
gpg -u $HARBIAN_SIGNING_KEY -bao Release.gpg Release


cd $BUILD_DIR
rm -f extrafiles
sha256sum $(find * -type f | egrep -v '(pool|i18n|dep11|source)/|Contents-.*\.(gz|diff)|installer|binary-|(In)?Release(.gpg)?|\.changes' | sort | sed -e "/^conf/d"  -e "/^db/d") > /tmp/extrafile
gpg --no-options --batch --no-tty --armour --personal-digest-preferences=SHA256  --no-options --batch --no-tty --armour --default-key $HARBIAN_SIGNING_KEY --clearsign --output extrafiles /tmp/extrafile

cd $BUILD_DIR/output
mkdir custompkg
mkdir profiles
cp $WORK_DIR/profile/* profiles/
cp $WORK_DIR/pkg/*.deb custompkg

build-simple-cdd --profiles-udeb-dist buster --debian-mirror http://$WEB_IP/debian/ --dist buster --security-mirror http://$WEB_IP/debian --keyring /etc/apt/trusted.gpg.d/harbian-archive.gpg --local-packages custompkg/ -p harbian

