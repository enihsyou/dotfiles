#!/usr/bin/env bash
DISKNAME=${1-RAM}
IMAGE_LOCATION=${2-"/Users/enihsyou/Library/RAM.dmg"}
DISK_LOCATION=/Volumes/${DISKNAME}

# Free up disk space before backup
# delete all Chrome user caches
rm -rf $DISK_LOCATION/Cache/Chrome/*
# clear compile caches
rm -f $DISK_LOCATION/Compile/*

sudo hdiutil create -srcfolder $DISK_LOCATION $IMAGE_LOCATION -ov
sudo chown enihsyou $IMAGE_LOCATION
