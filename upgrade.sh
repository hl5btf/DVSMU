#!/bin/bash

# dvsMU내의 메뉴에서 upgrade하면 이 프로그램이 실행됨
# dvsMU 개발시에, 정식 발표버전과 그 이전 버전의 내용이 달라짐. 이에 따라 정식버전 발표시에 그 이전의 내용과 다른 내용을 수정하는 내용이 있음. (man_log 관련한 내용)
# 차후에 upgrade 할 내용이 있으면 여기에 계속 주가하면 됨.
# 차후에 변수가 추가될때를 고려하여 변수가 추가되는 루틴을 미리 작성해 둠.

#====== man_log 다운로드 및 crontab 설정 =====================================================
function set_crontab() {
FILE_CRON=/etc/crontab

if [ ! -e $EILE_CRON ]; then
	sudo wget -O /usr/local/dvs/man_log https://raw.githubusercontent.com/hl5btf/DVSMU/main/man_log > /dev/null 2>&1
	sudo chmod +x /usr/local/dvs/man_log
fi

cron_daily_time=$(sed -n -e '/cron.daily/p' $FILE_CRON | cut -f 2 -d' ')
cron_daily_min=$(sed -n -e '/cron.daily/p' $FILE_CRON | cut -f 1 -d' ')
cron_daily_min_plus_3=$((cron_daily_min + 3))
cron_daily_min_plus_4=$((cron_daily_min + 4))

# <<<25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )>>>

if [[ ! -z `sudo grep "time" $FILE_CRON` ]]; then
	sudo sed -i -e "/time/ c time=3" $FILE_CRON
else
	echo "time=3" | sudo tee -a $FILE_CRON
fi

if [[ ! -z `sudo grep "man_log" $FILE_CRON` ]]; then
	sudo sed -i -e "/man_log/ c 0 3 * * * root /usr/local/dvs/man_log" $FILE_CRON
else
	echo "0 3 * * * root /usr/local/dvs/man_log" | sudo tee -a $FILE_CRON
fi

if [[ ! -z `sudo grep "reboot" $FILE_CRON` ]]; then
	sudo sed -i -e "/reboot/ c reboot=yes" $FILE_CRON
else
	echo "reboot=yes" | sudo tee -a $FILE_CRON
fi

if [[ ! -z `sudo grep "DMRIds" $FILE_CRON` ]]; then
	sudo sed -i -e "/DMRIds/ c $cron_daily_min_plus_3 $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh" $FILE_CRON
else
	echo "$cron_daily_min_plus_3 $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh" | sudo tee -a $FILE_CRON
fi
}

#====== 주파수가 000000000으로 되어 있으면 430000000로 변경하는 루틴 =========================
function freq_0_to_430() {

update_ini="sudo ${MB}dvswitch.sh updateINIFileValue"

source /var/lib/dvswitch/dvs/var00.txt > /dev/null 2>&1
if [ $rx_freq = 000000000 ]; then
	file=/var/lib/dvswitch/dvs/var00.txt
	tag=rx_freq; value=430000000
	sudo sed -i -e "/^$tag=/ c $tag=$value" $file
	tag=tx_freq; value=430000000
	sudo sed -i -e "/^$tag=/ c $tag=$value" $file
fi

# 만약 password의 값이 있다면 지우도록 수정.
sudo sed -i -e "/^bm_password=/ c bm_password=" $file

source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1
if [ $rx_freq = 000000000 ]; then
	file=/var/lib/dvswitch/dvs/var.txt
	tag=rx_freq; value=430000000
	sudo sed -i -e "/^$tag=/ c $tag=$value" $file
	tag=tx_freq; value=430000000
	sudo sed -i -e "/^$tag=/ c $tag=$value" $file
fi

source /opt/MMDVM_Bridge/MMDVM_Bridge.ini > /dev/null 2>&1
if [ $RXFrequency = "000000000" ]; then
	file=/opt/MMDVM_Bridge/MMDVM_Bridge.ini
	section=Info; tag=RXFrequency; value=430000000
	$update_ini $file $section $tag $value
	section=Info; tag=TXFrequency; value=430000000
	$update_ini $file $section $tag $value
fi

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"
for user in $user; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
	if [ $rx_freq = 000000000 ]; then
		file=/var/lib/dvswitch/dvs/var${user}.txt
		tag=rx_freq; value=430000000
		sudo sed -i -e "/^$tag=/ c $tag=$value" $file
		tag=tx_freq; value=430000000
		sudo sed -i -e "/^$tag=/ c $tag=$value" $file
	fi

	source /opt/user${user}/MMDVM_Bridge.ini > /dev/null 2>&1
	if [ $RXFrequency = "000000000" ]; then
		file=/opt/user${user}/MMDVM_Bridge.ini
		section=Info; tag=RXFrequency; value=430000000
		$update_ini $file $section $tag $value
		section=Info; tag=TXFrequency; value=430000000
		$update_ini $file $section $tag $value
	fi
fi
done
}

#====== 변수가 추가될때 처리하는 루틴 시작부분 =============================================
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
file=dvsmu
sudo wget -O /usr/local/dvs/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file
sudo chmod +x /usr/local/dvs/$file

file=DMRIds_chk.sh
sudo wget -O /usr/local/dvs/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file
sudo chmod +x /usr/local/dvs/$file

# sudo wget -O /usr/local/dvs/dvsmu https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu
# sudo wget -O /usr/local/dvs/DMRIds_chk.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/DMRIds_chk.sh

sleep 10

set_crontab

freq_0_to_430

# var_added

