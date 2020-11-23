#!/bin/bash

#sudo wget -O /usr/local/dvs/dvsmu https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu
#sudo chmod +x /usr/local/dvs/dvsmu

#----변수가 추가될때 처리하는 루틴 시작부분-------------------------------------------------------
function var_added() {
#sudo wget -O /var/lib/dvswitch/dvs/var00.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/var00.txt > /dev/null 2>&1

TERM=ansi whiptail --title "$T029" --infobox "사용자설정이 있어서 시간이 걸립니다." 8 60

# When updating, the stanzas will be appended to var.txt, if not exist.
new_var="test ttt"
# default value will be applied once, at the first time
new_val=("" ttt)

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"
for user in $user; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then

file=/var/lib/dvswitch/dvs/var${user}.txt

for var in ${new_var}; do
        if [[ -z `sudo grep "^$var" $file` ]]; then
                echo "$var=" | sudo tee -a $file > /dev/null 2>&1
                val=${new_val[$n]}
                update_var $var $val
        fi
        n=$(($n+1))
done
n=0

    sudo systemctl stop mmdvm_bridge${user} > /dev/null 2>&1
#   sudo systemctl stop analog_bridge${user} > /dev/null 2>&1
#   sudo systemctl stop md380-emu${user} > /dev/null 2>&1

speep 1

#file=/opt/user${user}/MMDVM_Bridge.ini
#    $update_ini $file Info Power ${pwr}
#    $update_ini $file Info Description "${desc}"

    sudo systemctl start mmdvm_bridge${user} > /dev/null 2>&1
#   sudo systemctl start analog_bridge${user} > /dev/null 2>&1
#   sudo systemctl start md380-emu${user} > /dev/null 2>&1
fi
done
}
#----변수가 추가될때 처리하는 루틴 끝 부분-------------------------------------------------------

var_added

