#!/usr/bin/env bash
DISKNAME=${1-RAM}
IMAGE_LOCATION=${2-"/Users/enihsyou/Library/RAM.dmg"}
DISK_LOCATION=/Volumes/${DISKNAME}
#INFO=`diskutil info /Volumes/${DISKNAME} | sed -n -E 's/^.*Part of Whole:.*(disk.*[0-9])/\1/p'`

#hdiutil detach $INFO

sudo hdiutil create -srcfolder $DISK_LOCATION $IMAGE_LOCATION -ov
sudo chown enihsyou $IMAGE_LOCATION
