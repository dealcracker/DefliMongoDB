# Defli MongoDB Connector Install Script
This shell script installs the Defli MongoDB Connector on a Defli Ground Station by automating the official installation instructions. This script is compatible with Ubuntu 22.04 and 23.04 64-bit.


## MongoDB Connector Install Script
Use this script to install the new MongoDB connector on your existing Defli Ground station.

### Usage
```
sudo bash -c "$(wget -O - https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/installMongo.sh)"
```
	
## Defli Ground Station Install Script
Use this script to install the Defli ground station on a new ground station device. Note that this script will reboot your device at the end of the installation. 

### Usage
```
sudo bash -c "$(wget -O - https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/installDefli.sh)"
```
After successful installation, please run the MongoDB Connector install script.



## SOCAT Removal Script
Use this script to remove the old obsolete SOCAT connector from your ground station device.

### Usage
```
sudo bash -c "$(wget -O - https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/removeSOCAT.sh)"
```
 
