#!/bin/bash
# Copyright (c) 2019 crds.co 
# credits-auto.sh
# credits masternode installation for Ubuntu 16.04 and Ubuntu 18.04
# ATTENTION: The firewall part will disable all services like, http, https and dns ports.

#Warning this script will install all dependencies that you are need for this installation.
echo "WARNING: This script will download some dependencies"
printf "Press Ctrl+C to cancel or Enter to continue:" 
read IGNORE

sleep 10;
echo "starting downloading credits dependencies...."
apt install software-properties-common curl -y

#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "IMPORTANT!!!! This script must be run as root (sudo su) first then run the script once again."
   echo "DO NOT RUN THIS SCRIPT WITH YOUR USER AND WITH SUDO IN COMBINATION!" 
   exit 1
fi

while true; do
 if [ -d ~/.credits ]; then
   printf "~/.credits/ already exists! The installer will delete this folder. Continue anyway?(Y/n)"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      pID=$(ps -ef | grep creditsd | awk '{print $2}')
      kill ${pID}
      rm -rf ~/.credits/
      break
   else
      if [ ${REPLY} == "n" ]; then
        exit
      fi
   fi
 else
   break
 fi
done


# Warning that the script will reboot your server once it's done with your credits-NODE
echo "WARNING: This script will reboot the server once it's done with your credits node."
printf "Press Ctrl+C to cancel or Enter to continue: "
read IGNORE

cd
# Changing the SSH Port to a custom number is a good in a security measure against DDOS/botnet attacks
printf "Custom SSH Port other than 22(Enter to ignore): "
read VARIABLE
_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing masternode genkey
printf "Enter Masternode PrivateKey: "
read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get your IP address of your vps which will be hosting the masternode
_nodeIpAddress=`curl ipecho.net/plain`
echo _nodeIpAddress
# Make a new directory for credits daemon
rm -r ~/.credits/
mkdir ~/.credits/
touch ~/.credits/credits.conf

# Change the directory to ~/.credits
cd ~/.credits/

echo "Downloading the latest bootstrap from github repository" 
wget https://github.com/CRDS/Credits/releases/download/v1.4.0.0/bootstrap.tar.gz
tar -xvzf bootstrap.tar.gz

# Create the initial credits.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
rpcport=31050
port=31000
onlynet=IPV4
maxconnections=64
masternode=1
externalip=${_nodeIpAddress}:31000
masternodeprivkey=${_nodePrivateKey}
" > credits.conf
cd

# Downloading Crdits source from github

echo "Download credits wallet from repository"
wget --no-check-certificate https://github.com/CRDS/Credits/releases/download/v1.4.0.0/credits-1.4.0-linux.tar.gz

echo "unpack credits tar.xz files"
tar -xvzf ./credits-1.4.0-linux.tar.gz
chmod +x ./credits-1.4.0-linux/*

echo "Put all executable files to /usr/bin"
cp ./credits-1.4.0-linux/creditsd /usr/bin/
cp ./credits-1.4.0-linux/credits-cli /usr/bin/

echo "remove all temp files!"
rm -r ./credits-1.4.0-linux/
rm -r ./credits-1.4.0-linux.tar.gz

# Create a directory for credits's cronjobs
echo "Adding all credits scripts to crontab"
rm -r credits-auto/credits
mkdir -p credits-auto/credits

# Change the directory to ~/credits-auto/
cd ~/credits-auto/credits
sleep 10;

# Download the appropriate scripts #edit
wget https://raw.githubusercontent.com/razerrazer/credits-AUTO/master/checkrun.sh
wget https://raw.githubusercontent.com/razerrazer/credits-AUTO/master/clearcreditslog.sh
wget https://raw.githubusercontent.com/razerrazer/credits-AUTO/master/daemonchecker.sh

# Create a cronjob for making sure creditsd runs after a reboot
if ! crontab -l | grep "@reboot creditsd"; then
  (crontab -l ; echo "@reboot creditsd") | crontab -
fi

# Create a cronjob for making sure creditsd is always running
if ! crontab -l | grep "~/credits-auto/credits/checkrun.sh"; then
  (crontab -l ; echo "*/5 * * * * ~/credits-auto/credits/checkrun.sh") | crontab -
fi

# Create a cronjob for making sure the daemon is never stuck
if ! crontab -l | grep "~/credits-auto/credits/daemonchecker.sh"; then
  (crontab -l ; echo "*/30 * * * * ~/credits-auto/credits/daemonchecker.sh") | crontab -
fi

# Create a cronjob for making sure creditsd is always up-to-date
#if ! crontab -l | grep "~/credits-auto/credits/upgrade.sh"; then
#  (crontab -l ; echo "0 0 */1 * * ~/credits-auto/credits/upgrade.sh") | crontab -
#fi

# Create a cronjob for clearing the log file
if ! crontab -l | grep "~/credits-auto/credits/clearcreditslog.sh"; then
  (crontab -l ; echo "0 0 */2 * * ~/credits-auto/credits/clearcreditslog.sh") | crontab -
fi

# Give execute permission to the cron scripts
chmod 0700 ./checkrun.sh
chmod 0700 ./daemonchecker.sh
chmod 0700 ./clearcreditslog.sh

# Change the SSH port
sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# Firewall security measures
apt install ufw -y
ufw disable
ufw allow 31000
ufw allow "$_sshPortNumber"/tcp
ufw limit "$_sshPortNumber"/tcp
ufw logging on
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Reboot the server after installation is done.
 read -r -p "reboot your server to compelete the installation? [Y/n]" response
 response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    /sbin/reboot
 fi
