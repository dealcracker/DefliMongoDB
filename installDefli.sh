#!/bin/bash
# Install Defli including MongoDB connector
# Copyright (c) 2023 dealcracker
#
# last modified: 2020-Oct-05


#enforce sudo
if ! [[ $EUID = 0 ]]; then
    echo "Please run this script with 'sudo'..."
    exit 1
fi

#change to user's home dir
user_dir=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
cd $user_dir

#get the user name
user_name=sudo who am i | awk '{print $1}'

#prompt for coordinate
echo "==================== Defli ====================="
echo "Installing Defli with no connector." 
echo "Please be sure your RTL-SDR dongle is connected."
echo ""
echo "Enter the geogrphical coordinates of your Defli ground station (decimal)"

read -p "Latitude:  " latitude
read -p "Longitude: " longitude

apt update
apt install bc

if (( $(echo "$latitude < -90.0" | bc -l) )) && (( $(echo "$latitude > 90.0" | bc -l) )); then 
  echo "The latitude value you entered is invalid. Aborting installation."
  exit 1
fi

if (( $(echo "$Longitude < -180.0" | bc -l) )) && (( $(echo "$Longitude > 180.0" | bc -l) )); then 
  echo "The Longitude value you entered is invalid. Aborting installation."
  exit 1
fi

echo ""
echo "Updating package list..."
# Update the package list
apt update -y

echo""
echo"Installing A-DSB Resder..."
bash -c "$(wget -O - https://github.com/wiedehopf/adsb-scripts/raw/master/readsb-install.sh)"

readsb-set-location $latitude $longitude

#install graphs1090
echo""
echo"Installing Graphs1090..."
bash -c "$(curl -L -o - https://github.com/wiedehopf/graphs1090/raw/master/install.sh)" 

echo "Installation Finished - Reboot Require!"
echo "Rebooting in 5 seconds! Press Ctrl-C to abort"
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
reboot

