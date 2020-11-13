#!/bin/bash

# sudo \cp -f /var/lib/dvswitch/dvs/lan/korean.txt /var/lib/dvswitch/dvs/lan/language.txt

sudo chmod +x /home/dvswitch/*.service
sudo chmod +x /home/dvswitch/dvsm.sh
sudo chmod +x /home/dvswitch/dvsmu
sudo mv /home/dvswitch/var00.txt /var/lib/dvswitch/dvs/
sudo mv /home/dvswitch/*.service /var/lib/dvswitch/dvs/
sudo mv /home/dvswitch/dvsmu /usr/local/dvs/
sudo mkdir /var/lib/dvswitch/dvs/adv/user00
sudo mv /home/dvswitch/dvsm.* /var/lib/dvswitch/dvs/adv/user00/
sudo mkdir /var/lib/dvswitch/dvs/adv/user00EN
sudo mkdir /var/lib/dvswitch/dvs/adv/user00KR
sudo mv /home/dvswitch/EN/*.* /var/lib/dvswitch/dvs/adv/user00EN/
sudo mv /home/dvswitch/KR/*.* /var/lib/dvswitch/dvs/adv/user00KR/

sudo rmdir /home/dvswitch/EN
sudo rmdir /home/dvswitch/KR

sudo rm /home/dvswitch/basic_config.sh

exit 0