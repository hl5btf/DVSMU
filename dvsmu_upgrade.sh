#!/bin/bash

# dvsMU내의 메뉴에서 upgrade하면 이 프로그램이 실행됨
# dvsMU 개발시에, 정식 발표버전과 그 이전 버전의 내용이 달라짐. 이에 따라 정식버전 발표시에 그 이전의 내용과 다른 내용을 수정하는 내용이 있음. (man_log 관련한 내용)
# 차후에 upgrade 할 내용이 있으면 여기에 계속 주가하면 됨.
# 차후에 변수가 추가될때를 고려하여 변수가 추가되는 루틴을 미리 작성해 둠.
# 이미 있는 내용은 추가하지 않음.

file="/var/lib/dvswitch/dvs/lan/language.txt"
if [ ! -f "$file" ]; then
    sudo cp /var/lib/dvswitch/dvs/lan/korean.txt $file
fi
# language.txt 가 없으면 아래 source에서 에러가 발생함
source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1

user_array=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40)

#====== replace_var00_txt =============================================
function replace_var00_txt() {
# 최초에 var00.txt를 만들었을때 설치했던 사용자를 위함
echo
echo ">>> replace_var00_txt"
file=var00.txt
dir=/var/lib/dvswitch/dvs
sudo wget -O ${dir}/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file > /dev/null 2>&1
}

#====== replace_freq_of_all_users =============================================
function replace_freq_of_all_users() {
# 주파수가 00000 일 경우에만, 430으로 수정
echo
echo ">>> replace_freq_of_all_users"

source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1
if [ "$rx_freq" = "000000000" ]; then
    file=/var/lib/dvswitch/dvs/var.txt
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
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
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

#====== add_45039_for_fvrt =============================================
function add_45039_for_fvrt() {
# DMR_fvrt_list.txt 수정
echo
echo ">>> add_45039_for_fvrt"

file=/var/lib/dvswitch/dvs/tgdb/DMR_fvrt_list.txt
if [ ! -f "$file" ] || [[ -z $(sudo grep "45039" "$file") ]]; then
    sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/tgdb_KR/DMR_fvrt_list.txt > /dev/null 2>&1
fi

file=/var/lib/dvswitch/dvs/tgdb/KR/DMR_fvrt_list.txt
if [ ! -f "$file" ] || [[ -z $(sudo grep "45039" "$file") ]]; then
    sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/tgdb_KR/DMR_fvrt_list.txt > /dev/null 2>&1
fi

for user in "${user_array[@]}"; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    file=/var/lib/dvswitch/dvs/tgdb/user${user}/DMR_fvrt_list.txt
    if [ ! -f "$file" ] || [[ -z $(sudo grep "45039" "$file") ]]; then
        sudo wget -O /var/lib/dvswitch/dvs/tgdb/user${user}/DMR_fvrt_list.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/tgdb_KR/DMR_fvrt_list.txt > /dev/null 2>&1
    fi
fi
done
}

#====== add_talkeralias =============================================
function add_talkeralias() {
echo
echo ">>> add_talkeralias"

source /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1

if ! sudo grep -q "talkerAlias" /var/lib/dvswitch/dvs/var.txt; then
    echo "talkerAlias=" | sudo tee -a /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1
fi

#=================================================================================================
######## MAIN USER의 talkerAlias는 기본값을 그대로 두기 위해서 아래의 부분은 remark 처리함. #######

#file=/opt/MMDVM_Bridge/DVSwitch.ini
#file_var=/var/lib/dvswitch/dvs/var.txt
#update_ini="sudo /opt/MMDVM_Bridge/dvswitch.sh updateINIFileValue"

#        # file에 talkerAlias 항목이 있으면 값을 가져온다
#        if sudo grep -q "talkerAlias" "$file"; then
#                dvs_TA=$($update_ini $file DMR talkerAlias)  # 라인의 내용 추출
#                dvs_TA=$(echo "$dvs_TA" | sed -E 's/^[^=]*=\s*//;s/;.*//;s/^[[:space:]]*//;s/[[:space:]]*$//') # 라인에서 값을 추출
#        else
#            dvs_TA=""
#        fi

#        var_TA="$talkerAlias"

#        # file에 talkerAlias라는 텍스트가 있으면
#        if sudo grep -q "talkerAlias" "$file"; then
#                # ((dvs_TA에 %callsign이 포함) 또는 (dvs_TA가 공란))이면
#                if [[ "$dvs_TA" == *"%callsign"* || -z "$dvs_TA" ]]; then
#                        tag=talkerAlias; value="dvsMultiUser by HL5KY"
#                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var

#                        sudo systemctl stop mmdvm_bridge > /dev/null 2>&1
#                        $update_ini $file DMR talkerAlias "dvsMultiUser by HL5KY"
#                        sudo systemctl start mmdvm_bridge > /dev/null 2>&1

#                # dvs_TA가 공란이 아니면
#                elif [[ -n "$dvs_TA" ]]; then
#                        tag=talkerAlias; value="$dvs_TA"
#                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var
#                fi
#        fi
##    $update_ini $file Info Description "${desc}"
#=================================================================================================

for user in "${user_array[@]}"; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    if ! sudo grep -q "talkerAlias" /var/lib/dvswitch/dvs/var${user}.txt; then
        echo "talkerAlias=" | sudo tee -a /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
    fi

file=/opt/user${user}/DVSwitch.ini
file_var=/var/lib/dvswitch/dvs/var${user}.txt

        # file에 talkerAlias 항목이 있으면 값을 가져온다
        if sudo grep -q "talkerAlias" "$file"; then
                dvs_TA=$($update_ini $file DMR talkerAlias)  # 라인의 내용 추출
                dvs_TA=$(echo "$dvs_TA" | sed -E 's/^[^=]*=\s*//;s/;.*//;s/^[[:space:]]*//;s/[[:space:]]*$//') # 라인에서 값을 추출
        else
            dvs_TA=""
        fi

        var_TA="$talkerAlias"

        # file에 talkerAlias라는 텍스트가 있으면
        if sudo grep -q "talkerAlias" "$file"; then
                # ((dvs_TA에 %callsign이 포함) 또는 (dvs_TA가 공란))이면
                if [[ "$dvs_TA" == *"%callsign"* || -z "$dvs_TA" ]]; then
                        tag=talkerAlias; value="dvsMultiUser by HL5KY"
                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var

                        sudo systemctl stop mmdvm_bridge > /dev/null 2>&1
                        $update_ini $file DMR talkerAlias "dvsMultiUser by HL5KY"
                        sudo systemctl start mmdvm_bridge > /dev/null 2>&1

                # dvs_TA가 공란이 아니면
                elif [[ -n "$dvs_TA" ]]; then
                        tag=talkerAlias; value="$dvs_TA"
                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var
                fi
        fi
#    $update_ini $file Info Description "${desc}"
fi
done
}

#====== download_and_update_apps =============================================
function download_and_update_apps() {
echo
echo ">>> download_and_update_apps"

files="man_log DMRIds_chk.sh bm_watchdog.sh config_main_user.sh auto_upgrade.sh"

for file in $files; do
sudo wget -O /usr/local/dvs/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file > /dev/null 2>&1
sudo chmod +x /usr/local/dvs/$file
done

echo
echo ">>> dvsmu 설치"

file=dvsmu
# 아키텍처 정보
ARCH_DPKG=$(dpkg --print-architecture)   # 예: armhf, arm64, amd64
ARCH_UNAME=$(uname -m)                   # 예: armv7l, aarch64, x86_64

# 아키텍처 및 배포판 기반 분기
if [[ "$ARCH_DPKG" == "armhf" || "$ARCH_UNAME" == "armv7l" ]]; then
    echo ">>> 32비트 ARM 시스템"
    file_download=dvsmu_armhf_glibc228

elif [[ "$ARCH_DPKG" == "arm64" || "$ARCH_UNAME" == "aarch64" ]]; then
    echo ">>> 64비트 ARM 시스템"
    file_download=dvsmu_arm64_glibc231

elif [[ "$ARCH_DPKG" == "amd64" || "$ARCH_UNAME" == "x86_64" ]]; then
    echo ">>> 64비트 PC 시스템"
    file_download=dvsmu_amd64_glibc231
else
    echo "dvsMU 설치 불가"
fi

sudo wget -O /usr/local/dvs/$file https://raw.githubusercontent.com/hl5btf/DVSMU/main/$file_download > /dev/null 2>&1
sudo chmod +x /usr/local/dvs/$file
}

#====== set_crontab =============================================
function set_crontab() {
echo
echo ">>> set_crontab"

FILE_CRON=/etc/crontab

value_time=$(grep -oP 'time=\K[^#\s]+' "$FILE_CRON")
if [ -z "$value_time" ]; then value_time=5; fi

if grep -q "reboot" "$FILE_CRON"; then
        value_reboot=$(grep -oP 'reboot=\K[^#\s]+' "$FILE_CRON")
fi


sudo sed -i '/time/d' "$FILE_CRON"
sudo sed -i '/reboot/d' "$FILE_CRON"
sudo sed -i '/man_log/d' "$FILE_CRON"
sudo sed -i '/DMRIds_chk.sh/d' "$FILE_CRON"
sudo sed -i '/bm_watchdog.sh/d' "$FILE_CRON"
sudo sed -i '/auto_upgrade.sh/d' "$FILE_CRON"


echo "#time=$value_time" | sudo tee -a $FILE_CRON > /dev/null 2>&1

if [ "$value_reboot" = "yes" ]; then
        echo "#reboot=yes" | sudo tee -a $FILE_CRON > /dev/null 2>&1
else
        echo "#reboot=no" | sudo tee -a $FILE_CRON > /dev/null 2>&1
fi

echo "0 $value_time * * * root flock -n /var/lock/man_log.lock /usr/local/dvs/man_log" | sudo tee -a $FILE_CRON > /dev/null 2>&1
echo "28 6 * * * root flock -n /var/lock/DMRIds_chk.lock /usr/local/dvs/DMRIds_chk.sh" | sudo tee -a $FILE_CRON > /dev/null 2>&1
echo "*/5 * * * * root flock -n /var/lock/bm_watchdog.lock /usr/local/dvs/bm_watchdog.sh" | sudo tee -a $FILE_CRON > /dev/null 2>&1
echo "3 3 * * * root flock -n /var/lock/auto_upgrade.lock /usr/local/dvs/auto_upgrade.sh" | sudo tee -a $FILE_CRON > /dev/null 2>&1
}

#====== add_variables =============================================
function add_variables() {
#sudo wget -O /var/lib/dvswitch/dvs/var00.txt https://raw.githubusercontent.com/hl5btf/DVSMU/main/var00.txt > /dev/null 2>&1
# 기존에 있는 변수는 값을 변경하지 않는다. (사용자가 변경한 값을 유지하도록)
# 기존에 있는 변수의 값을 변경하려면 update_var 을 사용해야 한다.
# each item needs space in between. if the item is character, it needs quotation marks.
echo
echo ">>> add_variables"
echo
function do_add() {
new_var="txgain_asl txgain_stfu txgain_intercom original_bm_address"
new_val=(0.35 0.35 0.35 "")

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
    source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    file=/var/lib/dvswitch/dvs/var${user}.txt
    do_add; n=0
fi
done
}

#=======================
# MAIN SCRIPT
#=======================
replace_var00_txt
replace_freq_of_all_users
add_45039_for_fvrt
add_talkeralias
download_and_update_apps
set_crontab
add_variables


