sudo service nginx start
sudo service ssh start
sudo mount -t drvfs '\\ENIHSYOU_NAS\Storage' /mnt/m
sudo mount -t drvfs '\\ENIHSYOU_NAS\PT' /mnt/n
DISPLAY=localhost:0 gnome-terminal
aria2c
