#!/bin/bash
# Remove the SOCAT connector
# Copyright (c) 2023 dealcracker
#
# last modfied: 2020-Oct-3


#enforce sudo
if ! [[ $EUID = 0 ]]; then
    echo "Please run this script with 'sudo'..."
    exit 1
fi

#change to user's home dir
cd ~/

echo "============= Remove SOCAT ==============="
echo "Removing the obsolete SOCAT Defli connector" 

systemctl stop defli_feeder
systemctl disable defli_feeder 
rm -f /usr/lib/systemd/system/defli_feeder.service
rm -f /usr/lib/systemd/system/readsb.timer

echo ""
echo "All done...have a nice day!"