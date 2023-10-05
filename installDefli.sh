#!/bin/bash
# Install Defli including MongoDB connector
# Copyright (c) 2023 dealcracker
#
# last modified: 2020-Oct-03


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
echo "Installing Defli and the MongoDB connector." 
echo "Please be sure your RTL-SDR dongle is connected."
echo ""
echo "Enter the geogrphical coordinates of your Defli ground station (decimal)"

read -p "Latitude:  " latitude
if (( $(echo "$latitude < -90.0" | bc -l) )) && (( $(echo "$latitude > 90.0" | bc -l) )); then 
  echo "The latitude value you entered is invalid. Aborting installation."
  exit 1
fi

read -p "Longitude: " longitude
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

#Determine IP address to use in config.py
#test if localhost is reachable
echo "Determining local IP address..."
ping -c 3 localhost > /dev/null 2>&1
if [ $? -eq 0 ]; then
  ip_address="localhost"
  echo "Using localhost instead of fixed IP address"
else
  # get the eth0 ip address
  ip_address=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d'/' -f1)
  #Check if eth0 is up and has an IP address
  if [ -n "$ip_address" ]; then
    echo "Using wired ethernet IP address: $ip_address"
  else
    # Get the IP address of the Wi-Fi interface using ip command
    ip_address=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d'/' -f1)
    if [ -n "$ip_address" ]; then
      echo "Using wifi IP address: $ip_address"
    else
      echo "Unable to determine your device IP address"
      echo "No IP address. Installation Failed."
      exit 1
    fi
  fi
fi


echo ""
echo "Cloning ABS-D data collector for MongoDB..."
#clone adsb-data-collector-mongodb
git clone https://github.com/dbsoft42/adsb-data-collector-mongodb.git

echo ""
echo "Installing Python..."
# Install python3-pip
apt install -y python3-pip

#patch coroutines if needed (experimental)
#Attempt 1
if [ -e "/usr/lib/python3.10/asyncio/coroutines.py" ]; then
  mv /usr/lib/python3.11/asyncio/coroutines.py /usr/lib/python3.11/asyncio/coroutines.py20230927 > /dev/null 2>&1
  cp /usr/lib/python3.10/asyncio/coroutines.py /usr/lib/python3.11/asyncio/coroutines.py > /dev/null 2>&1
fi
#Attempt 2
if [ -e "/snap/core22/867/usr/lib/python3.10/asyncio/coroutines.py" ]; then
  mv /usr/lib/python3.11/asyncio/coroutines.py /usr/lib/python3.11/asyncio/coroutines.py20230927 > /dev/null 2>&1
  cp /snap/core22/867/usr/lib/python3.10/asyncio/coroutines.py /usr/lib/python3.11/asyncio/coroutines.py > /dev/null 2>&1
fi

#BM - Changed to this code section to fix ubuntu
apt install python3-aiohttp -y 
apt install python3-motor -y
apt install python3-dateutil -y
apt install python3-dnspython -y

echo ""
echo "Preparing the connector config.py file..."
# copy the default config.py template
cd adsb-data-collector-mongodb
rm -f config.py 
cp config_template.py config.py

# replace text in config.py
original_line1="username:password@url.mongodb.net/myFirstDatabase"
new_line1="team:kaPAIYJz1EhpWtTO@defli1.snqvy.mongodb.net/"

original_line2=": 'adsb'"
new_line2=": 'defli1'"

original_line3="http://localhost/dump1090/data/aircraft.json"
new_line3="http://"$ip_address"/tar1090/data/aircraft.json"

sed -i "s|$original_line1|$new_line1|g" "config.py"
sed -i "s|$original_line2|$new_line2|g" "config.py"
sed -i "s|$original_line3|$new_line3|g" "config.py"

echo ""
echo "Preparing the adsb_collector service..."
#get the working directory
current_dir=$(pwd)
chown -R $user_name:$user_name $current_dir

#compose the exec start line
exec_start_line="ExecStart=/usr/bin/python3 $current_dir/adsb-data-collector.py"

#remove any existing adsb_collector.service file
if [ -e "/lib/systemd/system/adsb_collector.service" ]; then
	rm -f /lib/systemd/system/adsb_collector.service
	echo "Removing exiting service file..."
fi

# Create the service file and add the first line of text
touch /lib/systemd/system/adsb_collector.service

# Check if the file exists
if [ ! -e "/lib/systemd/system/adsb_collector.service" ]; then
  echo "Error: Could not create service file."
  echo "Aborting installation"
  exit 1
fi

# Add needed lines ot service file
echo "[Unit]" >> /lib/systemd/system/adsb_collector.service
echo "Description=adsb_collector" >> /lib/systemd/system/adsb_collector.service
echo "After=multi-user.target" >> /lib/systemd/system/adsb_collector.service
echo "[Service]" >> /lib/systemd/system/adsb_collector.service
echo "Type=simple" >> /lib/systemd/system/adsb_collector.service
echo "$exec_start_line" >> /lib/systemd/system/adsb_collector.service
echo "Restart=on-abort" >> /lib/systemd/system/adsb_collector.service
echo "[Install]" >> /lib/systemd/system/adsb_collector.service
echo "WantedBy=multi-user.target" >> /lib/systemd/system/adsb_collector.service

#enable and start the adsb colletor service
systemctl enable adsb_collector 

echo "Reboot Require!"
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

