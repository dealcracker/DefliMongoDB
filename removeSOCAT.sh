#!/bin/bash
# Remove the SOCAT connector
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

echo "============= Remove SOCAT ==============="
echo "Removing the obsolete SOCAT Defli connector" 

systemctl stop defli_feeder
systemctl disable defli_feeder 
rm -f /usr/lib/systemd/system/defli_feeder.service
echo ""
echo "All done...have a nice day!"