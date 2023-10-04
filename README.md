# Defli MongoDB Connector Install Script
This shell script installs the Defli MongoDB Connector on a Defli Ground Station by automating the official installation instructions. This script is compatible with Ubuntu 22.04 and 23.04 64-bit.


## MongoDB Connector Install Script
Use this script to install the new MongoDB connector on your existing Defli Ground station.

### Usage
```
curl -sL https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/installMongo.sh | sudo bash
```
	
## Full Defli Ground Station Install Script
Use this script to install the full Defli ground station including the MongoDB connector on a new ground station device. Note that this script will reboot your device at the end of the installation. Also, you may need to manually reboot your device a second time before the connector will run successfully.

After installation and reboot, use the following command to confirm that the MongoDB connector service is running. 
```
sudo systemctl status adsb_collector
```
### Usage
```
curl -sL https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/installDefli.sh | sudo bash
```



## SOCAT Removal Script
Use this script to remove the old obsolete SOCAT connector from your ground station device.

### Usage
```
curl -sL https://raw.githubusercontent.com/dealcracker/DefliMongoDB/master/removeSOCAT.sh | sudo bash
```
 
