#!/bin/bash

#=================================================================================================
# 또 다른 설치 파일은 github/hl5ky/setup 이며, 내용은 아래와 같고, 바이너리 파일로 되어 있다.
# 바이너리 파일을 실행하면, 지금 보고 있는 github/hl5btf/setu.sh를 실행하게 된다.
##!/bin/bash
#file=/usr/sbin/muset
#sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/setup.sh > /dev/null 2>&1
#sudo chmod +x $file > /dev/null 2>&1
#$file
#sudo rm $file
#=================================================================================================

clear

echo
echo
echo "----------------  Please Wait  ---------------------"

if [ ! -d /var/lib/dvswitch/dvs ] || [ ! -d /usr/local/dvs ]; then
echo
echo
echo "--------  DVSwitch가 설치되지 않았습니다  ----------"
echo
echo
exit 0
fi

sudo wget -O /var/lib/dvswitch/dvs/var00.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/var00.txt > /dev/null 2>&1


files="analog_bridge00.service mmdvm_bridge00.service md380-emu00.service"

for file in $files; do
sudo wget -O /var/lib/dvswitch/dvs/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file > /dev/null 2>&1
sudo chmod +x /var/lib/dvswitch/dvs/$file
echo "----------------------------------------------------"
done


sudo wget -O /usr/local/dvs/dvsmu https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu > /dev/null 2>&1
sudo chmod +x /usr/local/dvs/dvsmu
echo "----------------------------------------------------"

sudo mkdir /var/lib/dvswitch/dvs/adv/user00 > /dev/null 2>&1
sudo wget -O /var/lib/dvswitch/dvs/adv/user00/dvsm.macro https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsm.macro > /dev/null 2>&1
sudo wget -O /var/lib/dvswitch/dvs/adv/user00/dvsm.adv https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsm.adv > /dev/null 2>&1
echo "----------------------------------------------------"
sudo wget -O /var/lib/dvswitch/dvs/adv/user00/dvsm.basic https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsm.basic > /dev/null 2>&1
sudo wget -O /var/lib/dvswitch/dvs/adv/user00/dvsm.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsm.sh > /dev/null 2>&1
sudo chmod +x /var/lib/dvswitch/dvs/adv/user00/dvsm.sh
echo "----------------------------------------------------"

sudo mkdir /var/lib/dvswitch/dvs/adv/user00EN > /dev/null 2>&1
sudo mkdir /var/lib/dvswitch/dvs/adv/user00KR > /dev/null 2>&1

files="adv_audio.txt adv_dmr.txt adv_hotspot.txt adv_main.txt adv_managetg.txt adv_resetfvrt.txt adv_rxgain.txt adv_tgref.txt adv_tools.txt adv_txgain.txt"

for file in $files; do
sudo wget -O /var/lib/dvswitch/dvs/adv/user00EN/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/EN/$file > /dev/null 2>&1
sudo wget -O /var/lib/dvswitch/dvs/adv/user00KR/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/KR/$file > /dev/null 2>&1
echo "----------------------------------------------------"
done

sudo wget -O /usr/local/dvs/man_log https://raw.githubusercontent.com/hl5btf/DVSMU/main/man_log > /dev/null 2>&1
sudo chmod +x /usr/local/dvs/man_log

echo "-------------  Please Wait 10 sec  -----------------"
sudo apt-get update > /dev/null 2>&1
echo "----------------------------------------------------"
sudo apt-get install multitail > /dev/null 2>&1


#--------------------------------------------------------

path=$(echo $PATH)

if [[ "$path" =~ "dvs" ]]; then
        echo "------------------  FINISHED  ----------------------"
        echo
        echo "----------------  run < dvsmu >  -------------------"
        echo
        echo

        sudo rm ./setup > /dev/null 2>&1
        exit 0

else
        echo "------------------  FINISHED  ----------------------"
        echo
        echo "--------- 재부팅후 < dvsmu > 실행 가능 -------------"
        echo
        echo "---------- 재부팅 하시겠습니까? (y/n) --------------"
        read reply
        if [ "$reply" = Y ] || [ "$reply" = y ] || [ "$reply" = "" ]; then
        clear
        echo
        echo
        echo
        echo
        echo "------------- SSH 연결이 끊어집니다. ---------------"
        echo
        echo
                sudo rm ./setup > /dev/null 2>&1
                sudo reboot
        fi

        exit 0
fi

#--------------------------------------------------------
