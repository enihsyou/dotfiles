sudo service nginx start
sudo service php7.0-fpm start
sudo service ssh start
sudo service mysql start
sudo service postgresql start
#sudo mongod &
#sudo service redis-server start
sudo mount -t drvfs '\\ENIHSYOU_NAS\Storage' /mnt/m
sudo mount -t drvfs '\\ENIHSYOU_NAS\PT' /mnt/n
DISPLAY=localhost:0 gnome-terminal
aria2c &
