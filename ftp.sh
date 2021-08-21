#!/bin/bash

sudo apt update
sudo apt  install vsftpd
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original

sudo systemctl start vsftpd
sudo systemctl enable vsftpd

sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 990/tcp
sudo ufw allow 40000:50000/tcp

declare -a StringArray=("nodeflux" "donkey" "gandalf")
for val in ${StringArray[@]}; do
   sudo adduser $val
   sudo mkdir /home/$val/ftp
   sudo chown nobody:nogroup /home/$val/ftp
   sudo chmod a-w /home/$val/ftp
done

sudo sed -i 's|#write_enable=YES|write_enable=YES|' /etc/vsftpd.conf
sudo sed -i 's|#chroot_local_user=YES|chroot_local_user=YES|' /etc/vsftpd.conf

sudo tee -a /etc/vsftpd.conf > /dev/null <<EOT
user_sub_token=$USER
local_root=/home/$USER/ftp' >> /etc/vsftpd.conf
pasv_min_port=40000
pasv_max_port=50000
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
EOT

sudo touch /etc/vsftpd.userlist
declare -a StringArray=("nodeflux" "donkey" "gandalf")
for val in ${StringArray[@]}; do
   echo "$val" | sudo tee -a /etc/vsftpd.userlist
done

sudo systemctl restart vsftpd
