#!/bin/bash

# dvsMU내의 메뉴에서 upgrade하면 이 프로그램이 실행됨
# dvsMU 개발시에, 정식 발표버전과 그 이전 버전의 내용이 달라짐. 이에 따라 정식버전 발표시에 그 이전의 내용과 다른 내용을 수정하는 내용이 있음. (man_log 관련한 내용)
# 차후에 upgrade 할 내용이 있으면 여기에 계속 주가하면 됨.
# 차후에 변수가 추가될때를 고려하여 변수가 추가되는 루틴을 미리 작성해 둠.

#----변수가 추가될때 처리하는 루틴 시작부분-------------------------------------------------------
function var_added() {
#sudo wget -O /var/lib/dvswitch/dvs/var00.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/var00.txt > /dev/null 2>&1

# When updating, the stanzas will be appended to varxx.txt, if not exist.
# each item needs space in between. no qutation marks are needed
new_var=""
# default value will be applied once, at the first time
# each item needs space in between. if the item is character, it needs quotation marks.
new_val=()

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

file=/opt/user${user}/DVSwitch.ini
        if [ "${talkerAlias}" = "" ];
        then    sudo sed -i -e "/talkerAlias/ c talkerAlias = " $file
        else    $update_ini $file DMR talkerAlias "${talkerAlias}"
        fi
#    $update_ini $file Info Description "${desc}"

    sudo systemctl start mmdvm_bridge${user} > /dev/null 2>&1
#   sudo systemctl start analog_bridge${user} > /dev/null 2>&1
#   sudo systemctl start md380-emu${user} > /dev/null 2>&1
fi
done
}

################################################
# MAIN PROGRAM
################################################
sudo wget -O /usr/local/dvs/dvsmu https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu
sudo chmod +x /usr/local/dvs/dvsmu

#---- /etc/cron.daily/man_log 삭제 및 man_log 다시 다운로드----
sudo rm /etc/cron.daily/man_log
sudo rm /etc/cron.daily/man_log.sh

sudo wget -O /usr/local/dvs/man_log https://raw.githubusercontent.com/hl5btf/DVSMU/main/man_log > /dev/null 2>&1
sudo chmod +x /usr/local/dvs/man_log

#---- /etc/crontab의 daily 부분 시간을 최초 상태로 되돌리기--------------
#file=/etc/crontab
#line_no=$(grep -n "daily" $file -a | cut -d: -f1)
#line=$(cat $file | sed -n ${line_no}p)
#min=${line:0:2}

#if [ $min != 25 ]; then
sudo sed -i -e "/daily/ c 25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )" $file
#fi

#---- man_log 실행을 위한 초기 설정 -----------------
# 기존설정이 있다면, 새로운 초기설정으로 변경 / 없으면 초기설정
file=/etc/crontab
if [[ ! -z `sudo grep "time" $file` ]]; then
	line_no=$(grep -n "time=" $file -a | cut -d: -f1)
	line=$(cat $file | sed -n ${line_no}p)
	time=$(echo $line | cut -d '=' -f 2)

	sudo sed -i -e "/reboot/ c 0 $time * * * root /usr/local/dvs/man_log" $file
	echo "reboot=yes" | sudo tee -a $file > /dev/null 2>&1
else
	echo "time=3" | sudo tee -a $file > /dev/null 2>&1
	echo "0 3 * * * root /usr/local/dvs/man_log" | sudo tee -a $file > /dev/null 2>&1
fi

sleep 10

# var_added

