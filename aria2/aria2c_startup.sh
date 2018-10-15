#!/usr/bin/env bash
sudo mount -t drvfs '\\ENIHSYOU_NAS\Storage' /mnt/m
sudo mount -t drvfs '\\ENIHSYOU_NAS\PT' /mnt/n
aria2c -D
