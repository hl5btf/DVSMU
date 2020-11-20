#!/bin/bash

sudo wget -O /usr/local/dvs/dvsmu https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu
sudo chmod +x /usr/local/dvs/dvsmu

#----v.1.4.5에서 var.txt의 Description이 바뀌기 때문에 처리하는 내용-------------------------------------------------------
sudo wget -O /var/lib/dvswitch/dvs/var00.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/var00.txt > /dev/null 2>&1

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then

    TERM=ansi whiptail --title "$T029" --infobox "user${user} 처리중" 8 60

    update_var pwr 0
    update_var hgt 0
    update_var desc dvsMU

    sudo systemctl stop mmdvm_bridge${user} > /dev/null 2>&1
#   sudo systemctl stop analog_bridge${user} > /dev/null 2>&1
#   sudo systemctl stop md380-emu${user} > /dev/null 2>&1

speep 1

file=/opt/user${user}/MMDVM_Bridge.ini
    $update_ini $file Info Power ${pwr}
    $update_ini $file Info Height ${hgt}
    $update_ini $file Info Description "${desc}"

    sudo systemctl start mmdvm_bridge${user} > /dev/null 2>&1
#   sudo systemctl start analog_bridge${user} > /dev/null 2>&1
#   sudo systemctl start md380-emu${user} > /dev/null 2>&1
fi
done
#----v.1.4.5에서 var.txt의 Description이 바뀌기 때문에 처리하는 내용. 끝부분--------------------------------------------------

