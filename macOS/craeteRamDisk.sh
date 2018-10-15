#!/usr/bin/env bash
SIZE=2048
DISKNAME=RAM
DISK_ID=`hdiutil attach -nomount ram://$(( ${SIZE} * 1024 * 1024 / 512 ))`
diskutil partitionDisk $DISK_ID GPT APFS "$DISKNAME" 0

# Oneline version
#diskutil partitionDisk `hdiutil attach -nomount ram://8388608` GPT APFS "RAM" 0

cd /Volumes/$DISKNAME
mkdir -p Cache/Chrome
mkdir -p Compile/Hypers
mkdir -p Temp
