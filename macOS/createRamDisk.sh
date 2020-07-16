#!/usr/bin/env bash

[ -n "$DEBUG" ] && set -x

SIZE=${1-2048}
DISKNAME=${2-RAM}

BASE="/Volumes/$DISKNAME"
[[ -e "$BASE" ]] && exit 0

info() {
	echo "$(date +"%Y-%m-%d %H:%M:%S"): $@"
}

DEVICE_IDENTIFIER=$(diskutil info "$DISKNAME" 2> /dev/null | sed -n -E 's/^.*Device Identifier:.*(disk.*[0-9]).*/\1/p')
if [[ -n $DEVICE_IDENTIFIER ]]; then
	info mount exist volume
	hdiutil mountvol "$DEVICE_IDENTIFIER"
	exit 0
fi

info create new ramdisk
DISK_ID=$(hdiutil attach -nomount ram://$((SIZE * 1024 * 1024 / 512)) | sed -e 's/[[:space:]]*$//') # a sector is 512 bytes
diskutil partitionDisk "$DISK_ID" GPT APFS "$DISKNAME" 0

# Oneline version
#diskutil partitionDisk `hdiutil attach -nomount ram://8388608` GPT APFS "RAM" 0

# Backup location
IMAGE_LOCATION=${3-"/Users/enihsyou/Library/$DISKNAME.dmg"}
if [ -e "$IMAGE_LOCATION" ]; then
	info restore backup image
	# asr imagescan --source $IMAGE_LOCATION --nostream
	asr restore --source "$IMAGE_LOCATION" --target "$BASE" --erase --noverify --noprompt
else
	info initinalize new ramdisk

	if [[ ! -e "$BASE" ]]; then
		info mount disk during initinalizing

		echo $(diskutil info "$DISKNAME")
		DEVICE_IDENTIFIER=$(diskutil info "$DISKNAME" | sed -n -E 's/^.*Device Identifier:.*(disk.*[0-9]).*/\1/p')
		hdiutil mountvol "$DEVICE_IDENTIFIER"
	fi

	cd "$BASE" || exit 1
	mkdir -p Cache/{Chrome,IDEA,PHP,Maven,Gradle,Shell}
	# mkdir -p Compile
	# mkdir -p Temp/logs
fi
