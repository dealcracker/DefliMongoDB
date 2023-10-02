#!/bin/bash
# install the Defli MongoDB connector
# Copyright (c) 2023 dealcracker

if ! [[ $EUID = 0 ]]; then
    echo "Please run this script with 'sudo'..."
    exit 1
fi

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

echo "Updating package list..."
# Update the package list
apt update -y

echo "Cloning ABS-D data collector for MongoDB..."
#clone adsb-data-collector-mongodb
git clone https://github.com/dbsoft42/adsb-data-collector-mongodb.git

echo "Installing dependencies..."
# Install python3-pip
apt install -y python3-pip

#patch coroutines if needed (experimental)
cp /usr/lib/python3.10/asyncio/coroutines.py  /usr/lib/python3.11/asyncio/coroutines.py 2>/dev/null

# Istall pip modules
pip3 install aiohttp motor pymongo python-dateutil dnspython

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

echo "Preparing the adsb_collector service..."
#get the working directory
current_dir=$(pwd)

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
systemctl start adsb_collector

echo "Waiting for service to start..."
sleep 3

service_name="adsb_collector"

#get the service status
status=$(systemctl is-active "$service_name")

# Check the status
case "$status" in
  "active")
    echo "Installation Complete. $service_name is running."
    echo "You can enter 'sudo systemctl status adsb_collector' to check the status."
    ;;
  "inactive")
    echo "Installation Complete. Warning: $service_name is not running."
    echo "Try entering 'sudo systemctl start adsb_collector' to start the service."
    echo "Then enter 'sudo systemctl status adsb_collector' to check the status."
    ;;
  "failed")
    echo "Installation Complete. Error: $service_name is in a failed state."
    echo "Try entering 'sudo systemctl start adsb_collector' to start the service."
    echo "Then enter 'sudo systemctl status adsb_collector' to check the status."
    ;;
  *)
    echo "Installation Complete. Status of $service_name: $status"
    echo "You can enter 'sudo systemctl status adsb_collector' to check the status."
    ;;
esac
