#!/bin/bash

file=/usr/local/dvs/dvsmu_upgrade.sh
sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu_upgrade.sh > /dev/null 2>&1
sudo chmod +x $file
sudo $file
sudo rm $file

exit 0
