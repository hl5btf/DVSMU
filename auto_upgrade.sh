#!/bin/bash

# /usr/local/dvs/auto_upgrade.sh
#===================================
SCRIPT_VERSION="2.0"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2025-08-29"
#===================================
# 외부 스크립트(dvsstart.sh)에서 auto_upgrade.sh를 실행할때 로그기록을 하지 않으려면 sudo env DISABLE_LOG=1 /usr/local/dvs/auto_upgrade.sh

#-----------------------------------------------------------------------------------
# auto_upgrade.sh 파일의 변경이 있으면 tmp에 다운로드 (본 스크립트의 마지막에 dst_auto로 복사)
	file=auto_upgrade.sh
	dst_auto="/usr/local/dvs/$file"
	tmp_auto="/tmp/$file"
	url="https://raw.githubusercontent.com/hl5btf/DVSMU/main"
	sudo wget -O "$tmp_auto" "$url/$file"
#-----------------------------------------------------------------------------------

source /usr/local/dvs/funcs.sh

LOG_FILE="/var/log/dvswitch/auto_upgrade.log"
TMP_FILE="/var/log/dvswitch/auto_upgrade.trim"
MAX_LINES=300

# 로그 없으면 생성
[ -f "$LOG_FILE" ] || sudo touch "$LOG_FILE"

# 로그 줄 수가 MAX_LINES를 넘으면 뒤에서 부터 남기고 앞쪽 자르기
#tail -n "$MAX_LINES" "$LOG_FILE" > "$TMP_FILE" && cp "$TMP_FILE" "$LOG_FILE"
sudo sh -c "tail -n '$MAX_LINES' '$LOG_FILE' > '$TMP_FILE' && cp --preserve=mode,ownership,timestamps '$TMP_FILE' '$LOG_FILE'"


[ -n "$DISABLE_LOG" ] || echo ">>> AutoUpgrade check started at $(date)" | sudo tee -a "$LOG_FILE"
# 외부 스크립트에서 auto_upgrade.sh를 실행할때 로그기록을 하지 않으려면 sudo env DISABLE_LOG=1 /usr/local/dvs/auto_upgrade.sh

# CHECK DVSwitch ===========================================================================

sudo apt-get update

[ -n "$DISABLE_LOG" ] || echo "> Check DVSwitch" | sudo tee -a "$LOG_FILE"

# dvswitch-server가 설치되어 있고, 업그레이드할 내용이 있으면
if dpkg -l | grep -q "^ii  dvswitch-server" && apt-get -s upgrade | grep -q "^Inst dvswitch-server "; then
    echo "> dvswitch-server가 설치되어 있고, 업그레이드가 가능합니다."
    # 여기에 업그레이드 명령 등 실행
    sudo apt-get install dvswitch-server -y

	# call Function
	main_user_dvswitch_upgrade
	[ -n "$DISABLE_LOG" ] || echo "> Found upgrade of DVSwitch" | sudo tee -a "$LOG_FILE"

#------ 추가사용자수 max_user 확인  -------------------------------
shopt -s nullglob; dirs=(/opt/user[0-9][0-9]); shopt -u nullglob
max_user=0
for d in "${dirs[@]}"; do
        n=${d#/opt/user}          # 예: "07", "15"
        if [[ $n =~ ^[0-9][0-9]$ ]] && (( 10#$n > max_user )); then
                max_user=$((10#$n))
        fi
done
#echo "$max_user"
#---------------------------------------------------------------

	# 01 ~ max_user 까지만 while 루프 실행
	idx=1
	while (( idx <= max_user )); do
        user=$(printf "%02d" "$idx")

		source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
  		if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
    		sudo systemctl stop mmdvm_bridge${user} analog_bridge${user} md380-emu${user} > /dev/null 2>&1

    		# call Function
      		sudo systemctl stop mmdvm_bridge${user} analog_bridge${user} md380-emu${user} > /dev/null 2>&1
		# restart루틴은 var_to_ini 함수 마지막 부분에 있음
    		file_copy_and_initialize ${user}
    		var_to_ini ${user} upgrade
		fi
	((idx++))
	done
	[ -n "$DISABLE_LOG" ] || echo "> DVSwitch upgrade done" | sudo tee -a "$LOG_FILE"
else
	[ -n "$DISABLE_LOG" ] || echo "> Current DVSwitch is the latest" | sudo tee -a "$LOG_FILE"
fi

sudo rm -f "$temp_func_file"

#----- execute dvsmu_upgrade.sh (only function download_and_update_apps --------------------------------------
file=dvsmu_upgrade.sh
tmp="/tmp/$file"
url="https://raw.githubusercontent.com/hl5btf/DVSMU/main"
sudo wget -O "$tmp" "$url/$file"  
sudo chmod +x $tmp
sudo $tmp call_from_auto_upgrade
sudo rm -f "$tmp"
#-----------------------------------------------------------------------------------
# tmp파일이 있고 && 크기가 0이 아니면서 && tmp와 dst의 내용이 다르면(변경이 되었으면)
if [ -s "$tmp_auto" ] && ! cmp -s -- "$tmp_auto" "$dst_auto"; then
	sudo mv -f "$tmp_auto" "$dst_auto"
	sudo chmod +x $dst_auto
	sudo rm -f "$tmp_auto"
        [ -n "$DISABLE_LOG" ] || echo "> [●] auto_upgrade.sh has updated to a new file" | sudo tee -a "$LOG_FILE"
else
	sudo rm -f "$tmp_auto"
	echo "> [✗] auto_upgrade.sh hasn't changed"
fi

[ -n "$DISABLE_LOG" ] || echo "------------------------------------------------------------" | sudo tee -a "$LOG_FILE"
