#!/usr/bin/env bash
DISKNAME=${1:-RAM}
IMAGE_LOCATION=${2:-"/Users/enihsyou/Library/RAM.dmg"}
DISK_LOCATION=/Volumes/${DISKNAME:-RAM}

# Free up disk space before backup
# delete all Chrome user caches
rm -rf $DISK_LOCATION/Cache/Chrome/*
# delete all Firefox user caches
rm -rf $DISK_LOCATION/Cache/Firefox/*
# delete all IDEA caches
rm -rf $DISK_LOCATION/Cache/IDEA/*
# clear compile caches
rm -rf $DISK_LOCATION/Compile/*

# make a backup of old image
function backup() {
    old_location=${1:?}
    new_location=${2:?}
    if [ -e "$old_location" ]; then
        echo "Move $old_location to $new_location"
        mv "$old_location" "$new_location"
    fi
}
backup "${IMAGE_LOCATION}.bak" "${IMAGE_LOCATION}.2.bak"
backup "${IMAGE_LOCATION}"     "${IMAGE_LOCATION}.bak"

sudo hdiutil create -srcfolder $DISK_LOCATION ${DISK_SIZE:+-size ${DISK_SIZE}} $IMAGE_LOCATION
sudo chown enihsyou $IMAGE_LOCATION
