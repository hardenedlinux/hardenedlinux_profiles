#!/bin/bash

## Make sure you create /data with proper permission if you don't want to run this script as root

BUILD_DIR=/data/mirror/debian
WORK_DIR=`pwd`
REPO_URL='http://deb.debian.org/debian'
HARBIAN_SIGNING_KEY=DA361430B802907E
WEB_IP='144.77.103.7'

mkdir -p $BUILD_DIR
cp $WORK_DIR/conf $BUILD_DIR -af
cd $BUILD_DIR
mkdir -p ./conf/filterlist/
mkdir -p $BUILD_DIR/output
touch ./conf/filterlist/debian-buster-src

reprepro -V update
