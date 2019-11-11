#!/usr/bin/env bash

[ -n "$DEBUG" ] && set -x

SIZE=${1-2048}
DISKNAME=${2-RAM}

BASE=/Volumes/$DISKNAME
[[ -e $BASE ]] && exit 0

DEVICE_IDENTIFIER=$( diskutil info "$DISKNAME" | sed -n -E 's/^.*Device Identifier:.*(disk.*[0-9]).*/\1/p' )
if [[ -n $DEVICE_IDENTIFIER ]]; then
    hdiutil mountvol "$DEVICE_IDENTIFIER"
    exit 0
fi

DISK_ID=$( hdiutil attach -nomount ram://$(( SIZE * 1024 * 1024 / 512 )) | sed -e 's/[[:space:]]*$//' ) # a sector is 512 bytes
diskutil partitionDisk "$DISK_ID" GPT APFS "$DISKNAME" 0

# Oneline version
#diskutil partitionDisk `hdiutil attach -nomount ram://8388608` GPT APFS "RAM" 0

# Backup location
IMAGE_LOCATION=${3-"/Users/enihsyou/Library/RAM.dmg"}
if [ "$DISKNAME" != "RAM" ]; then
    exit 0
elif [ -e "$IMAGE_LOCATION" ]; then
    # asr imagescan --source $IMAGE_LOCATION --nostream
    asr restore --source "$IMAGE_LOCATION" --target "$BASE" --erase --noverify --noprompt
else
    cd "$BASE" || exit 1
    mkdir -p Cache/{Chrome,IDEA,PHP}
    mkdir -p Compile
    mkdir -p Temp/logs
fi
