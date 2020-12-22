#!/bin/bash


dir=/usr/local/dvs
files="dvsmu man_log"
for file in $files; do
sudo wget -O ${dir}/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file
sudo chmod +x ${dir}/$file
done


dir=/var/lib/dvswitch/dvs
files="analog_bridge00.service md380-emu00.service mmdvm_bridge00.service var00.txt"
for file in $files; do
sudo wget -O ${dir}/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file
sudo chmod +x ${dir}/$file
done


sudo mkdir /var/lib/dvswitch/dvs/adv/user00
dir=/var/lib/dvswitch/dvs/adv/user00
files="dvsm.adv dvsm.basic dvsm.macro dvsm.sh"
for file in $files; do
sudo wget -O ${dir}/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file
sudo chmod +x ${dir}/$file
done


sudo mkdir /var/lib/dvswitch/dvs/adv/user00EN
dir=/var/lib/dvswitch/dvs/adv/user00EN
files="adv_audio.txt adv_dmr.txt adv_hotspot.txt adv_main.txt adv_managetg.txt adv_resetfvrt.txt adv_rxgain.txt adv_tgref.txt adv_tools.txt adv_txgai$
for file in $files; do
sudo wget -O ${dir}/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/EN/$file
done


sudo mkdir /var/lib/dvswitch/dvs/adv/user00KR
dir=/var/lib/dvswitch/dvs/adv/user00KR
files="adv_audio.txt adv_dmr.txt adv_hotspot.txt adv_main.txt adv_managetg.txt adv_resetfvrt.txt adv_rxgain.txt adv_tgref.txt adv_tools.txt adv_txgai$
for file in $files; do
sudo wget -O ${dir}/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/KR/$file
done


sudo rm ./config.sh

exit 0

