# Defli MongoDB Connector Install Script
This shell script installs the Defli MongoDB Connector on a Defli Ground Station by automating the official installation instructions. This script is compatible with Ubuntu 22.04 64-bit.

### Usage

1. Copy the installMongo.sh script to your user directory:

	wget https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/installMongo.sh

2. Make file executable	

	chmod +x installMongo.sh	

3. Run Script: 

	sudo ./installMongo.sh


Note that this script will attempt to use "localhost" in the tar1090 URL if it properly resolves on the host. If localhost does not resolve, the script will then check for a wired ethernet interface IP address. If that interface is down, the script will then attempt to use the IP address of the wireless wifi interface. 
