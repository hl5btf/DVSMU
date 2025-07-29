#!/bin/bash

# dvsMU내의 메뉴에서 upgrade하면 이 프로그램이 실행됨
# dvsMU 개발시에, 정식 발표버전과 그 이전 버전의 내용이 달라짐. 이에 따라 정식버전 발표시에 그 이전의 내용과 다른 내용을 수정하는 내용이 있음. (man_log 관련한 내용)
# 차후에 upgrade 할 내용이 있으면 여기에 계속 주가하면 됨.
# 차후에 변수가 추가될때를 고려하여 변수가 추가되는 루틴을 미리 작성해 둠.
# 이미 있는 내용은 추가하지 않음.

source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1

user_array=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40)

#====== replace_freq_of_all_users =============================================
function replace_freq_of_all_users() {

# 주파수가 00000 일 경우에만, 430으로 수정

source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1
if [ "$rx_freq" = "000000000" ]; then
    file=/var/lib/dvswitch/dvs/var.txt
    tag=rx_freq; value=430000000
    sudo sed -i -e "/^$tag=/ c $tag=$value" $file
    tag=tx_freq; value=430000000
    sudo sed -i -e "/^$tag=/ c $tag=$value" $file
fi

source /var/lib/dvswitch/dvs/var00.txt > /dev/null 2>&1
if [ "$rx_freq" = "000000000" ]; then
    file=/var/lib/dvswitch/dvs/var00.txt
    tag=rx_freq; value=430000000
    sudo sed -i -e "/^$tag=/ c $tag=$value" $file
    tag=tx_freq; value=430000000
    sudo sed -i -e "/^$tag=/ c $tag=$value" $file
fi

source /opt/MMDVM_Bridge/MMDVM_Bridge.ini > /dev/null 2>&1
update_ini="sudo /opt/MMDVM_Bridge/dvswitch.sh updateINIFileValue"
if [ "$RXFrequency" = "000000000" ]; then
    file=/opt/MMDVM_Bridge/MMDVM_Bridge.ini
    section=Info; tag=RXFrequency; value=430000000
    $update_ini $file $section $tag $value
    section=Info; tag=TXFrequency; value=430000000
    $update_ini $file $section $tag $value
fi

for user in "${user_array[@]}"; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
    update_ini="sudo /opt/user${user}/dvswitch.sh updateINIFileValue"
    if [ "$rx_freq" = "000000000" ]; then
        file=/var/lib/dvswitch/dvs/var${user}.txt
        tag=rx_freq; value=430000000
        sudo sed -i -e "/^$tag=/ c $tag=$value" $file
        tag=tx_freq; value=430000000
        sudo sed -i -e "/^$tag=/ c $tag=$value" $file
    fi

    source /opt/user${user}/MMDVM_Bridge.ini > /dev/null 2>&1
    if [ "$RXFrequency" = "000000000" ]; then
        file=/opt/user${user}/MMDVM_Bridge.ini
        section=Info; tag=RXFrequency; value=430000000
        $update_ini $file $section $tag $value
        section=Info; tag=TXFrequency; value=430000000
        $update_ini $file $section $tag $value
    fi
fi
done
}

#====== delete_stz_value_for_var00 =============================================
function delete_stz_value_for_var00() {
source /var/lib/dvswitch/dvs/var00.txt > /dev/null 2>&1
# 아래의 항목의 값은 지운다. 최초에 var00.txt를 만들었을때 설치했던 사용자를 위한 루틴 
file=/var/lib/dvswitch/dvs/var00.txt
sudo sed -i -e "/^bm_password=/ c bm_password=" $file
sudo sed -i "/^lat=/ c lat=" $file
sudo sed -i "/^lon=/ c lon=" $file
sudo sed -i "/^desc=/ c desc=dvsMU" $file
}

#====== add_45039_for_fvrt =============================================
function add_45039_for_fvrt() {
# DMR_fvrt_list.txt 수정
file=/var/lib/dvswitch/dvs/tgdb/DMR_fvrt_list.txt
if [[ -z $(sudo grep "45039" "$file") ]]; then
    sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/tgdb_KR/DMR_fvrt_list.txt > /dev/null 2>&1
fi

file=/var/lib/dvswitch/dvs/tgdb/KR/DMR_fvrt_list.txt
if [[ -z $(sudo grep "45039" "$file") ]]; then
    sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/tgdb_KR/DMR_fvrt_list.txt > /dev/null 2>&1
fi

for user in "${user_array[@]}"; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    file=/var/lib/dvswitch/dvs/tgdb/user${user}/DMR_fvrt_list.txt
    if [[ -z $(sudo grep "45039" "$file") ]]; then
        sudo wget -O /var/lib/dvswitch/dvs/tgdb/user${user}/DMR_fvrt_list.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/tgdb_KR/DMR_fvrt_list.txt > /dev/null 2>&1
    fi
fi
done
}

#====== add_talkeralias =============================================
function add_talkeralias() {

if [ -e /var/lib/dvswitch/dvs/var.txt ] && [ x${call_sign} != x ]; then
    source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1
    if ! sudo grep -q "talkerAlias"; then
        add_var_line talkerAlias ""
    fi
    sudo systemctl stop mmdvm_bridge > /dev/null 2>&1

    file=/opt/MMDVM_Bridge/DVSwitch.ini
        update_ini="sudo /opt/MMDVM_Bridge/dvswitch.sh updateINIFileValue"
        if [ "${talkerAlias}" = "" ];
        then    sudo sed -i -e "/talkerAlias/ c talkerAlias = " $file
        else    $update_ini $file DMR talkerAlias "${talkerAlias}"
        fi
#    $update_ini $file Info Description "${desc}"
    sudo systemctl start mmdvm_bridge > /dev/null 2>&1
fi

for user in "${user_array[@]}"; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
    sudo systemctl stop mmdvm_bridge${user} > /dev/null 2>&1

    file=/opt/user${user}/DVSwitch.ini
        update_ini="sudo /opt/user${user}/dvswitch.sh updateINIFileValue"
        if [ "${talkerAlias}" = "" ];
        then    sudo sed -i -e "/talkerAlias/ c talkerAlias = " $file
        else    $update_ini $file DMR talkerAlias "${talkerAlias}"
        fi
#    $update_ini $file Info Description "${desc}"
    sudo systemctl start mmdvm_bridge${user} > /dev/null 2>&1
fi
done
}

#====== download_and_update_apps =============================================
function download_and_update_apps() {
files="dvsmu man_log DMRIds_chk.sh bm_watchdog.sh config_main_user.sh auto_upgrade.sh"

for file in $files; do
sudo wget -O /usr/local/dvs/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file > /dev/null 2>&1
sudo chmod +x /usr/local/dvs/$file
done

# 필요시 아래와 같이 다운로드 가능
# sudo wget -O /usr/local/dvs/dvsmu https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu
# sudo wget -O /usr/local/dvs/man_log https://raw.githubusercontent.com/hl5btf/DVSMU/main/man_log
# sudo wget -O /usr/local/dvs/DMRIds_chk.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/DMRIds_chk.sh
}

#====== set_crontab =============================================
function set_crontab() {

FILE_CRON=/etc/crontab

if ! sudo grep -q "time=" "$FILE_CRON"; then
    echo "#time=3" | sudo tee -a $FILE_CRON
fi

if ! sudo grep -q "reboot=" "$FILE_CRON"; then
    echo "#reboot=yes" | sudo tee -a $FILE_CRON
fi

if ! sudo grep -q "man_log" "$FILE_CRON"; then
    echo "0 3 * * * root /usr/local/dvs/man_log" | sudo tee -a $FILE_CRON
fi

# DMRIds_chk.sh 는 아래와 같이 잘못 입력된 경우가 있기 때문에 그 라인을 완전히 변경하도록 한다
# $cron_daily_min_plus_3 $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh
if grep -q "DMRIds_chk.sh" /etc/crontab; then
    sudo sed -i '/DMRIds_chk.sh/d' $FILE_CRON
    echo "28 6 * * * root /usr/local/dvs/DMRIds_chk.sh" | sudo tee -a $FILE_CRON
fi

if ! sudo grep -q "bm_watchdog" "$FILE_CRON"; then
    echo "*/5 * * * * root /usr/local/dvs/bm_watchdog.sh" | sudo tee -a $FILE_CRON
fi

if ! sudo grep -q "auto_upgrade.sh" "$FILE_CRON"; then
    echo "5 3 * * * root /usr/local/dvs/auto_upgrade.sh" | sudo tee -a $FILE_CRON
fi
}

#====== add_variables =============================================
function add_variables() {
#sudo wget -O /var/lib/dvswitch/dvs/var00.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/var00.txt > /dev/null 2>&1
# 기존에 있는 변수는 값을 변경하지 않는다. (사용자가 변경한 값을 유지하도록)
# 기존에 있는 변수의 값을 변경하려면 update_var 을 사용해야 한다.
# each item needs space in between. if the item is character, it needs quotation marks.

new_var="txgain_asl txgain_stfu txgain_intercom original_bm_address"

new_val=(0.35 0.35 0.35 "")

function do_add() {
for var in ${new_var}; do
        if ! sudo grep -q "^$var" "$file"; then
                echo "$var=" | sudo tee -a $file > /dev/null 2>&1
                val=${new_val[$n]}
                sudo sed -i -e "/^$var=/ c $var=$val" $file
    fi
        n=$(($n+1))
done
}

file=/var/lib/dvswitch/dvs/var.txt
    do_add; n=0

file=/var/lib/dvswitch/dvs/var00.txt
    do_add; n=0

for user in "${user_array[@]}"; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
    file=/var/lib/dvswitch/dvs/var${user}.txt
    do_add; n=0
fi
done
}

#=======================
# MAIN SCRIPT
#=======================
replace_freq_of_all_users
delete_stz_value_for_var00
add_45039_for_fvrt
add_talkeralias

# 아래 3개는 Github hl5ky/dvsmu/stup.sh와 동일 (수정시 동일하게 수정해야 함)
download_and_update_apps
set_crontab
add_variables

