#!/bin/bash

#===================================
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2025-07-27"
#===================================

# dvsmu에서 필요한 함수만 불러오기
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

LOG_FILE="/var/log/dvswitch/auto_upgrade.log"

# 로그 없으면 생성
[ -f "$LOG_FILE" ] || sudo touch "$LOG_FILE"

# 로그 줄 수가 100줄 넘으면 최근 100줄만 유지
MAX_LINES=100
TOTAL_LINES=$(wc -l < "$LOG_FILE")

if [ "$TOTAL_LINES" -gt "$MAX_LINES" ]; then
    tail -n $MAX_LINES "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

echo "AutoUpgrade check started at $(date)" | sudo tee -a "$LOG_FILE"

# check DVSwitch -----------------------------------

sudo apt-get update

echo "Check DVSwitch" | sudo tee -a "$LOG_FILE"

if apt-get -s upgrade | grep -q "^Inst dvswitch-server "; then
	# call Function
	main_user_dvswitch_upgrade
	echo "Found upgrade of DVSwitch" | sudo tee -a "$LOG_FILE"

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
	echo "DVSwitch upgrade done" | sudo tee -a "$LOG_FILE"
else
	echo "Current DVSwitch is the latest" | sudo tee -a "$LOG_FILE"
fi

sudo rm -f "$temp_func_file"

# check dvsmu --------------------------

LOCAL_FILE="/usr/local/dvs/dvsmu"
REMOTE_URL="https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu"

LOCAL_VERSION=$(grep '^SCRIPT_VERSION=' "$LOCAL_FILE" | cut -d'"' -f2)
REMOTE_VERSION=$(curl -s --max-time 5 "$REMOTE_URL" | grep '^SCRIPT_VERSION=' | head -n 1 | cut -d'"' -f2)

# 두 버전 중 더 낮은(작은) 버전을 구함
LOWEST=$(printf '%s\n%s\n' "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | head -n 1)

echo "Check dvsmu" | sudo tee -a "$LOG_FILE"
if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
    echo "Current dvsmu v$LOCAL_VERSION is the latest" | sudo tee -a "$LOG_FILE"
elif [ "$LOWEST" = "$LOCAL_VERSION" ]; then
        echo "Found upgrade v$REMOTE_VERSION of dvsmu" | sudo tee -a "$LOG_FILE"
        file=/usr/local/dvs/dvsmu_upgrade.sh
        sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu_upgrade.sh > /dev/null 2>&1
        sudo chmod +x $file
        sudo $file
        sudo rm -f $file
        echo "dvsmu v$REMOTE_VERSION upgrade done" | sudo tee -a "$LOG_FILE"
else
        echo "can't check the version" | sudo tee -a "$LOG_FILE"
fi

echo "------------------------------------------------------------" | sudo tee -a "$LOG_FILE"

