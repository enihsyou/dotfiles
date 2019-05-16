#!/usr/bin/env bash
DISKNAME=${1:-RAM}
IMAGE_LOCATION=${2:-"/Users/enihsyou/Library/RAM.dmg"}
DISK_LOCATION=/Volumes/${DISKNAME:-RAM}

# Free up disk space before backup
# delete all Chrome user caches
rm -rf $DISK_LOCATION/Cache/Chrome/*
# delete all Firefox user caches
rm -rf $DISK_LOCATION/Cache/Firefox/*
# clear compile caches
rm -rf $DISK_LOCATION/Compile/*

sudo hdiutil create -srcfolder $DISK_LOCATION ${DISK_SIZE:+-size ${DISK_SIZE}} $IMAGE_LOCATION -ov
sudo chown enihsyou $IMAGE_LOCATION

