#### *A huge thank you goes out to @BigMaxi! His countless hours to improve and test these scripts have been invaluable!*

# Defli MongoDB Connector Install Script
These shell scripts help to install the Defli ground station. One script installs the base Defli ground station on a new device. Another script installs the new Defli MongoDB Connector on new or existing ground stations. A third script removes the old SOCAT connector from a ground station. These scripts are compatible with the 64-bit version of Ubuntu 20.04, 22.04, and 23.04 as well as Rasberry Pi OS. The current recommended OS from Defli Networks is Ubuntu 22.04. 

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

## Troubleshooting

### Service Failed To Start
If the MongoBD service does not start at the end of the MongoBD install script, try restarting the service.
```
sudo systemctl start adsb_collector
```
If the service still does not run, try rebooting the device. 
```
sudo reboot
```
Then check the service status again
```
sudo systemctl start adsb_collector
```

### Purple Screen

If during the installation you see a purple screen that asks "Which services should be restarted?", please hit enter to continue.

![alt text](https://github.com/dealcracker/DefliMongoDB/blob/main/purpleScreen.png?raw=true)
