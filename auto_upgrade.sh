#!/bin/bash

# /usr/local/dvs/auto_upgrade.sh
#===================================
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2025-07-27"
#===================================

# 외부스크립트(dvsstart.sh)에서 auto_upgrade.sh를 호출할때 로그기록이 필요없다면, sudo env DISABLE_LOG=1 /usr/local/dvs/auto_upgrade.sh
# dvsstart.sh 스크립트에서 호출함

#----------- dvsmu에서 필요한 함수만 불러오기---------------------------------
dvsmu_file="/usr/local/dvs/dvsmu"
temp_func_file="/tmp/temp_dvsmu_funcs.sh"
functions=("update_DV3000" "main_user_dvswitch_upgrade" "file_copy_and_initialize" "var_to_ini")

# 초기화
> "$temp_func_file"

for fname in "${functions[@]}"; do
    tmp_part="/tmp/func_${fname}.sh"
    > "$tmp_part"
    awk "/^function $fname *\\(\\)/,/^}/" "$dvsmu_file" > "$tmp_part"

    if [ -s "$tmp_part" ]; then
        cat "$tmp_part" >> "$temp_func_file"
        echo -e "\n" >> "$temp_func_file"
    fi
done

if [ -s "$temp_func_file" ]; then
    source "$temp_func_file"
fi
#----------- 함수 불러오기 끝 ------------------------------------

LOG_FILE="/var/log/dvswitch/auto_upgrade.log"
TMP_FILE="/var/log/dvswitch/auto_upgrade.trim"
MAX_LINES=300

# 로그 없으면 생성
[ -f "$LOG_FILE" ] || sudo touch "$LOG_FILE"

# 로그 줄 수가 MAX_LINES를 넘으면 최근 라인만 유지
tail -n "$MAX_LINES" "$LOG_FILE" > "$TMP_FILE" && cp "$TMP_FILE" "$LOG_FILE"

[ -n "$DISABLE_LOG" ] || echo "AutoUpgrade check started at $(date)" | sudo tee -a "$LOG_FILE"
# 외부 스크립트에서 auto_upgrade.sh를 실행할때 로그기록을 하지 않으려면 sudo env DISABLE_LOG=1 /usr/local/dvs/auto_upgrade.sh

# check DVSwitch -----------------------------------

sudo apt-get update

[ -n "$DISABLE_LOG" ] || echo "Check DVSwitch" | sudo tee -a "$LOG_FILE"

# dvswitch-server가 설치되어 있고, 업그레이드할 내용이 있으면
if dpkg -l | grep -q "^ii  dvswitch-server" && apt-get -s upgrade | grep -q "^Inst dvswitch-server "; then
    echo "dvswitch-server가 설치되어 있고, 업그레이드가 가능합니다."
    # 여기에 업그레이드 명령 등 실행
    sudo apt-get install dvswitch-server -y

	# call Function
	main_user_dvswitch_upgrade
	[ -n "$DISABLE_LOG" ] || echo "Found upgrade of DVSwitch" | sudo tee -a "$LOG_FILE"

	user_array="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40"

	for user in $user_array; do
		if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
			source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
    		sudo systemctl stop mmdvm_bridge${user} analog_bridge${user} md380-emu${user} > /dev/null 2>&1

    		# call Function
      		sudo systemctl stop mmdvm_bridge${user} analog_bridge${user} md380-emu${user} > /dev/null 2>&1
		# restart루틴은 var_to_ini 함수 마지막 부분에 있음
    		file_copy_and_initialize ${user}
    		var_to_ini ${user} upgrade
		fi
	done
	[ -n "$DISABLE_LOG" ] || echo "DVSwitch upgrade done" | sudo tee -a "$LOG_FILE"
else
	[ -n "$DISABLE_LOG" ] || echo "Current DVSwitch is the latest" | sudo tee -a "$LOG_FILE"
fi

sudo rm -f "$temp_func_file"

# check dvsmu --------------------------

LOCAL_FILE="/usr/local/dvs/dvsmu"
REMOTE_URL="https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu"

LOCAL_VERSION=$(grep '^SCRIPT_VERSION=' "$LOCAL_FILE" | cut -d'"' -f2)
REMOTE_VERSION=$(curl -s --max-time 5 "$REMOTE_URL" | grep '^SCRIPT_VERSION=' | head -n 1 | cut -d'"' -f2)

# 두 버전 중 더 낮은(작은) 버전을 구함
LOWEST=$(printf '%s\n%s\n' "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | head -n 1)

[ -n "$DISABLE_LOG" ] || echo "Check dvsmu" | sudo tee -a "$LOG_FILE"
if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
    [ -n "$DISABLE_LOG" ] || echo "Current dvsmu v$LOCAL_VERSION is the latest" | sudo tee -a "$LOG_FILE"
elif [ "$LOWEST" = "$LOCAL_VERSION" ]; then
        [ -n "$DISABLE_LOG" ] || echo "Found upgrade v$REMOTE_VERSION of dvsmu" | sudo tee -a "$LOG_FILE"
        file=/usr/local/dvs/dvsmu_upgrade.sh
        sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu_upgrade.sh > /dev/null 2>&1
        sudo chmod +x $file
        sudo $file
        sudo rm -f $file
        [ -n "$DISABLE_LOG" ] || echo "dvsmu v$REMOTE_VERSION upgrade done" | sudo tee -a "$LOG_FILE"
else
        [ -n "$DISABLE_LOG" ] || echo "can't check the version" | sudo tee -a "$LOG_FILE"
fi

[ -n "$DISABLE_LOG" ] || echo "------------------------------------------------------------" | sudo tee -a "$LOG_FILE"

