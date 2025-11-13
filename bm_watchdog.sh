#!/bin/bash

#===================================
SCRIPT_VERSION="Menu Script v.2.1"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2025/11/13"
#===================================

# 설정
hostfile="/var/lib/mmdvm/DMR_Hosts.txt"
bm_list_tmp_file="/var/tmp/bm_present_list.txt"
bm_status_tmp_file="/var/tmp/bm_watchdog_status.txt"
logfile="/var/log/dvswitch/bm_watchdog.log"
tmpfile="/var/log/dvswitch/bm.trim"
maxline=3000
email="onetree9@gmail.com"

# file이 없으면 새로 만들기
touch "$bm_list_tmp_file"
touch "$bm_status_tmp_file"
touch "$logfile"

# 외부 함수 로드
source /var/lib/dvswitch/dvs/var.txt
# source ${bm_list_tmp_file} - 해당 Function 에서 실행해야 함.
# source ${bm_status_tmp_file} - 해당 Function에서 실행해야 함.

# 변수 읽기
flagfile="/tmp/bm_watchdog_log_trimmed.flag"
today=$(date '+%Y-%m-%d')
hour=$(date '+%H')
TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 03시대에 한 번만 실행
if [ "$hour" == "03" ]; then
    # 플래그 파일이 없거나, 날짜가 오늘이 아니면 실행
    if [ ! -f "$flagfile" ] || [ "$(cat "$flagfile")" != "$today" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [•] 최근 $maxline줄만 보존하고 정리함" >> "$logfile"
	# 뒤에서 부터 남기고 자르기
	#tail -n "$maxline" "$logfile" > "$tmpfile" && cp "$tmpfile" "$logfile"
	sudo sh -c "tail -n '$maxline' '$logfile' > '$tmpfile' && cp --preserve=mode,ownership,timestamps '$tmpfile' '$logfile'"
        echo "$today" > "$flagfile"  # 오늘 실행했다고 기록
    fi
fi

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

# msmtp/mail 환경 자동 결정: MAIL_ENV 배열에 env-assignments 세팅
function prepare_mail_env() {
  REAL_USER="${SUDO_USER:-$(id -un)}"
  REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
  [ -z "$REAL_HOME" ] && REAL_HOME="$HOME"

  # msmtp 설정 파일 우선순위: 지정 MSMTP_CONFIG > ~/.msmtprc > /etc/msmtprc
  if [ -n "${MSMTP_CONFIG:-}" ] && [ -f "$MSMTP_CONFIG" ]; then
    MSMTP_CFG="$MSMTP_CONFIG"
  elif [ -n "$REAL_HOME" ] && [ -f "$REAL_HOME/.msmtprc" ]; then
    MSMTP_CFG="$REAL_HOME/.msmtprc"
  elif [ -f /etc/msmtprc ]; then
    MSMTP_CFG="/etc/msmtprc"
  else
    MSMTP_CFG=""
  fi

  MAIL_BIN="$(command -v mail || echo /usr/bin/mail)"
}

######################################################################
# extract_bm_list
######################################################################
# var${user}.txt에서  bm_address, original_bm_address 추출

function extract_bm_list() {

# 파일 초기화
> "$bm_list_tmp_file"

# 배열 초기화
declare -a now_bm_list
declare -a original_bm_list

# 중복 확인 함수
is_in_array() {
    local value="$1"
    shift
    for item in "$@"; do
        if [ "$item" = "$value" ]; then
            return 0
        fi
    done
    return 1
}

# now_bm_address 수집
# 01 ~ max_user 까지만 while 루프 실행
unset bm_address
idx=""
while (( idx <= max_user )); do
	if [ "$idx" = "" ]; then
		user=""
	else
		user=$(printf "%02d" "$idx")
	fi


    var_file="/var/lib/dvswitch/dvs/var${user}.txt"

    if [ -f "$var_file" ]; then
        source "$var_file"

	if [ "$bm_address" = "bm.dv.or.kr" ]; then
		bm_address="4501.master.brandmeister.network"
		update_var bm_address "$bm_address"
	fi

        if [ -n "$bm_address" ]; then
            if ! is_in_array "$bm_address" "${now_bm_list[@]}"; then
                now_bm_list+=("$bm_address")
            fi
        fi
    fi
((idx++))
done

# original_bm_address 수집
# 01 ~ max_user 까지만 while 루프 실행
unset original_bm_address
idx=""
while (( idx <= max_user )); do
	if [ "$idx" = "" ]; then
		user=""
	else
		user=$(printf "%02d" "$idx")
	fi

    var_file="/var/lib/dvswitch/dvs/var${user}.txt"

    if [ -f "$var_file" ]; then
        source "$var_file"
        if [ -n "$original_bm_address" ]; then
            if ! is_in_array "$original_bm_address" "${original_bm_list[@]}"; then
                original_bm_list+=("$original_bm_address")
            fi
        fi
    fi
((idx++))
done

# 결과를 배열로 저장 (bm_list_tmp_file에 덮어쓰기)
sed -i '/^#/d' "$bm_list_tmp_file"

{
echo "#=== 현재설정된 서버 리스트 ==="

    echo -n "now_bm_address=("
    for i in "${!now_bm_list[@]}"; do
        if [ "$i" -eq "$((${#now_bm_list[@]} - 1))" ]; then
            echo -n "${now_bm_list[$i]}"
        else
            echo -n "${now_bm_list[$i]} "
        fi
    done
    echo ")"

echo "#"
echo "#=== 복구를 위한 서버 리스트 ==="

    echo -n "original_bm_address=("
    for i in "${!original_bm_list[@]}"; do
        if [ "$i" -eq "$((${#original_bm_list[@]} - 1))" ]; then
            echo -n "${original_bm_list[$i]}"
        else
            echo -n "${original_bm_list[$i]} "
        fi
    done
    echo ")"
} > "$bm_list_tmp_file"
}
#----------- END OF extract_bm_list ----------------------------------

######################################################################
# normal_ping_test
######################################################################
# bm_list_tmp_file에서 now_bm_address 테스트

function normal_ping_test() {

source ${bm_list_tmp_file}
source ${bm_status_tmp_file}

sed -i '/^#/d' "$bm_status_tmp_file"
echo "#=== 현재설정된 서버 테스트 ===" >> "$bm_status_tmp_file"

for test_bm_address in "${now_bm_address[@]}"; do
    prefix="${test_bm_address%%.*}" # 결과 ex> 4501 or 41

    bm_prefix_ping_ok="bm_${prefix}_ping_ok"
    bm_prefix_ping_fail="bm_${prefix}_ping_fail"

    echo "$TIME - 정상 ping 테스트: $test_bm_address" >> "$logfile"

    if ping -c 1 -W 2 "$test_bm_address" > /dev/null 2>&1; then
        echo "$TIME - 연결 정상" >> "$logfile"
#        sed -i "/^${bm_prefix_ping_ok}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_ok}=0" >> "$bm_status_tmp_file"
        sed -i "/^${bm_prefix_ping_fail}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_fail}=0" >> "$bm_status_tmp_file"

    else
        eval "$bm_prefix_ping_fail=\$(( $bm_prefix_ping_fail + 1 ))"
        echo "$TIME - ping 실패 (${!bm_prefix_ping_fail}/3)" >> "$logfile"
#        sed -i "/^${bm_prefix_ping_ok}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_ok}=0" >> "$bm_status_tmp_file"
        sed -i "/^${bm_prefix_ping_fail}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_fail}=${!bm_prefix_ping_fail}" >> "$bm_status_tmp_file"
    fi
done
}
#----------- END OF normal_ping_test ---------------------------------

######################################################################
# replace_bm_address
######################################################################
# 대체 주소로 전환
function replace_bm_address() {

source ${bm_list_tmp_file}
source ${bm_status_tmp_file}

for test_bm_address in "${now_bm_address[@]}"; do
    prefix="${test_bm_address%%.*}" # 결과 ex> 4501 or 41

    bm_prefix_ping_ok="bm_${prefix}_ping_ok"
    bm_prefix_ping_fail="bm_${prefix}_ping_fail"

#echo "for loop - now_bm_add - $bm_prefix_ping_fail"
#echo "$(($bm_prefix_ping_fail))"

        if [[ "$(($bm_prefix_ping_fail))" =~ ^[0-9]+$ ]] && [ "$(($bm_prefix_ping_fail))" -ge 3 ]; then
		echo "$TIME - 3회 이상 실패: $test_bm_address -  대체 주소 탐색 시작" >> "$logfile"

		# 1. bm이라는 글자로 시작하는 줄만 배열로 저장
		mapfile -t bm_lines < <(grep '^BM' "$hostfile")
		total=${#bm_lines[@]}

		# 2. 현재 주소가 있는 인덱스 찾기
		current_index=-1
		for i in "${!bm_lines[@]}"; do
			set -- ${bm_lines[$i]}
			if [[ "$3" == "$test_bm_address" ]]; then
		        	current_index=$i
	        		break
	        	fi
		done

		# 3. 현재 test_bm_address가 있는지 확인
		if [ "$current_index" -lt 0 ]; then
        		current_index=0
		        offset=0   # ← 없으면 bm_lines의 첫 줄부터 테스트
		else
        		offset=1   # ← 있으면 현재 test_bm_address 다음 줄부터 테스트
		fi

		loop_count=0
		while true; do
        		try_index=$(( (current_index + offset) % total ))
			set -- ${bm_lines[$try_index]}
		        new_address=$3

        		# bm_list 의 라인에 주소필드가 비어있으면 다음 라인부터  루프 새로 시작
		        if [ -z "$new_address" ]; then
        			offset=$((offset + 1))
				continue
		        fi

			echo "$TIME - 대체 주소 테스트: $new_address (index $try_index)" >> "$logfile"

	        	if ping -c 1 -W 2 "$new_address" > /dev/null; then
        			echo "$TIME - 대체 주소 사용 가능" >> "$logfile"

				# 주소 전환 처리...
				# "" ~ max_user 까지만 while 루프 실행
				idx=""
				while (( idx <= max_user )); do
					if [ "$idx" = "" ]; then
						user=""
					else
						user=$(printf "%02d" "$idx")
					fi

					source_file=/var/lib/dvswitch/dvs/var${user}.txt
					source $source_file > /dev/null 2>&1
					present_bm_address=$bm_address

					if [ "$bm_address" = "$test_bm_address" ]; then
						bm_address=""
						update_var bm_address "$new_address"
				        	update_var original_bm_address "$test_bm_address"

						if [ -z "$user" ]; then
							ini_file="/opt/MMDVM_Bridge/MMDVM_Bridge.ini"
						else
							ini_file="/opt/user${user}/MMDVM_Bridge.ini"
						fi

					        $update_ini "$ini_file" "DMR Network" Address "$new_address"
					        sudo systemctl restart mmdvm_bridge${user}

				        	echo "$TIME - USER${user} 전환 완료: $present_bm_address -> $new_address" >> "$logfile"

						# 임시 변수 지우기
                                                sed -i "/^${bm_prefix_ping_ok}=.*/d" "$bm_status_tmp_file"
                                                sed -i "/^${bm_prefix_ping_fail}=.*/d" "$bm_status_tmp_file"

						# email 보내기
						source /var/lib/dvswitch/dvs/var.txt

						if [ "$call_sign" = "HL5KY" ]; then

prepare_mail_env

# ---- 여기부터 전송 ----
TO="${email:-}"   # 비어 있으면 스킵
SUBJECT="bm_watchdog - 마스터서버 장애 감지 및 서버 변경"

[ -z "$TO" ] && { logger -t bm_watchdog "email unset; skip"; exit 0; }

if [ -n "$MSMTP_CFG" ] && [ -d "$REAL_HOME" ]; then
  HOME="$REAL_HOME" MSMTP_CONFIG="$MSMTP_CFG" \
  "$MAIL_BIN" -a 'Content-Type: text/plain; charset=UTF-8' \
              -s "$SUBJECT" "$TO" <<EOF
${TIME:-$(date '+%F %T')}
USER${user:-}
초기 설정 주소: ${present_bm_address:-unknown}}
대체 변경 주소: ${new_address:-unknown}
EOF
else
  "$MAIL_BIN" -a 'Content-Type: text/plain; charset=UTF-8' \
              -s "$SUBJECT" "$TO" <<EOF
${TIME:-$(date '+%F %T')}
USER${user:-}
초기 설정 주소: ${present_bm_address:-${bm_address:-unknown}}
대체 변경 주소: ${new_address:-unknown}
EOF
fi

							# 다음의 두 가지 조건에 맞으면 email 전송
							# 주사용자에 설정한 마스터서버가 작동되지 않아서 서버를 변경한 경우
							# 주사용자의 호출부호가 HL5KY인 경우
							# 위의 조건뿐만 아니라 email은 관련 프로그램을 설치해야 작동함
						fi
					fi
				((idx++))
				done
				break
			else
				echo "$TIME - 대체 주소 ping 실패: $test_bm_address -> 다른 대체 주소 찾기" >> "$logfile"
			fi

	        	# 다음 인덱스로 이동
		        offset=$((offset + 1))
        		loop_count=$((loop_count + 1))

	        	# 순환 한 바퀴를 넘어서면 로그 출력
        		if (( offset % total == 0 )); then
				echo "$TIME - 한 바퀴 순환 완료, 계속 재시도 중 (순환 횟수: $((loop_count / total)))" >> "$logfile"
		        fi

        		# loop_count가 100이 되면 다시 0으로 초기화
	        	if (( loop_count >= 100 )); then
         			loop_count=0
			        echo "$TIME - loop_count가 100에 도달하여 초기화되었습니다." >> "$logfile"
		        fi
		done
	fi
done
}
#----------- END OF replace_bm_address --------------------------------

######################################################################
# restore_ping_test
######################################################################
# bm_list_tmp_file에서 original_bm_address 테스트

function restore_ping_test() {

source ${bm_list_tmp_file}
source ${bm_status_tmp_file}

echo "#" >> "$bm_status_tmp_file"
echo "#=== 복구를 위해 원래 서버 테스트 ===" >> "$bm_status_tmp_file"


for test_bm_address in "${original_bm_address[@]}"; do
    prefix="${test_bm_address%%.*}" # 결과 ex> 4501 or 41

    bm_prefix_ping_ok="bm_${prefix}_ping_ok"
    bm_prefix_ping_fail="bm_${prefix}_ping_fail"

    echo "$TIME - 복구 테스트 대상: $test_bm_address" >> "$logfile"

    if ping -c 1 -W 2 "$test_bm_address" > /dev/null 2>&1; then
        eval "$bm_prefix_ping_ok=\$(( $bm_prefix_ping_ok + 1 ))"
        echo "$TIME - 복구 ping 성공 (${!bm_prefix_ping_ok}/5): 5회 이상 성공시 새벽 3시에 복구 실행" >> "$logfile"
        sed -i "/^${bm_prefix_ping_ok}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_ok}=${!bm_prefix_ping_ok}" >> "$bm_status_tmp_file"
#        sed -i "/^${bm_prefix_ping_fail}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_fail}=0" >> "$bm_status_tmp_file"

    else
	sed -i "/^${bm_prefix_ping_ok}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_ok}=0" >> "$bm_status_tmp_file"
#        sed -i "/^${bm_prefix_ping_fail}=.*/d" "$bm_status_tmp_file"; echo "${bm_prefix_ping_fail}=0" >> "$bm_status_tmp_file"
	echo "$TIME - 복구 ping 실패" >> "$logfile"
    fi
done
}
#----------- END OF restore_ping_test --------------------------------

######################################################################
# restore_bm_address
######################################################################
#
function restore_bm_address() {

source ${bm_list_tmp_file}
source ${bm_status_tmp_file}

for test_bm_address in "${original_bm_address[@]}"; do
	prefix="${test_bm_address%%.*}" # 결과 ex> 4501 or 41

	bm_prefix_ping_ok="bm_${prefix}_ping_ok"
	bm_prefix_ping_fail="bm_${prefix}_ping_fail"

#echo "for 복구 loop - now_bm_add - $bm_prefix_ping_ok"
#echo "$(($bm_prefix_ping_ok))"

	if [[ "$(($bm_prefix_ping_ok))" =~ ^[0-9]+$ ]] && [ "$(($bm_prefix_ping_ok))" -ge 5 ] && [ "$hour" -eq 03 ]; then
#	if [[ "$(($bm_prefix_ping_ok))" =~ ^[0-9]+$ ]] && [ "$(($bm_prefix_ping_ok))" -ge 5 ]; then    #테스트를  위해서 시간 생략

        	#echo "$TIME - 복구 조건 충족, 주소 복원 시작 : $test_bm_address" >> "$logfile"
                echo "$TIME - 복구 조건 충족, 주소 복원 시작" >> "$logfile"

		# 주소 전환 처리...
		# "" ~ max_user 까지만 while 루프 실행
		idx=""
		while (( idx <= max_user )); do
			if [ "$idx" = "" ]; then
				user=""
			else
				user=$(printf "%02d" "$idx")
			fi

        		source_file=/var/lib/dvswitch/dvs/var${user}.txt
	            	source $source_file > /dev/null 2>&1
			present_bm_address=$bm_address
        		if [ "$original_bm_address" = "$test_bm_address" ]; then
				original_bm_address=""
                		update_var bm_address "$test_bm_address"
	                	update_var original_bm_address ""
	        	        if [ -z "$user" ]; then
        	        		ini_file="/opt/MMDVM_Bridge/MMDVM_Bridge.ini"
	        	        else
        			        ini_file="/opt/user${user}/MMDVM_Bridge.ini"
	                	fi
		                $update_ini "$ini_file" "DMR Network" Address "$test_bm_address"
        		        sudo systemctl restart mmdvm_bridge${user}

                                echo "$TIME - USER${user} 복원 성공: $present_bm_address -> $test_bm_address" >> "$logfile"

		                # 임시 변수 지우기
        		        sed -i "/^${bm_prefix_ping_ok}=.*/d" "$bm_status_tmp_file"
                		sed -i "/^${bm_prefix_ping_fail}=.*/d" "$bm_status_tmp_file"
				bm_short="${bm_address%%.*}"
				sed -i "/^${bm_short}=.*/d" "$bm_status_tmp_file"

		                # email 보내기
						source /var/lib/dvswitch/dvs/var.txt

						if [ "$call_sign" = "HL5KY" ]; then

prepare_mail_env

# ---- 여기부터 전송 ----
TO="${email:-}"   # 비어 있으면 스킵
SUBJECT="bm_watchdog - 원래의 마스터서버 주소로 복원"

[ -z "$TO" ] && { logger -t bm_watchdog "email unset; skip"; exit 0; }

if [ -n "$MSMTP_CFG" ] && [ -d "$REAL_HOME" ]; then
  HOME="$REAL_HOME" MSMTP_CONFIG="$MSMTP_CFG" \
  "$MAIL_BIN" -a 'Content-Type: text/plain; charset=UTF-8' \
              -s "$SUBJECT" "$TO" <<EOF
${TIME:-$(date '+%F %T')}
USER${user:-}
임시 사용 주소: ${present_bm_address:-unknown}}
복원된 원래 주소: ${new_address:-unknown}
EOF
else
  "$MAIL_BIN" -a 'Content-Type: text/plain; charset=UTF-8' \
              -s "$SUBJECT" "$TO" <<EOF
${TIME:-$(date '+%F %T')}
USER${user:-}
임시 사용 주소: ${present_bm_address:-unknown}}
복원된 원래 주소: ${new_address:-unknown}
EOF
fi
	        	        # 다음의 두 가지 조건에 맞으면 email 전송
        	        	# 주사용자에 설정한 마스터서버가 작동되지 않아서 서버를 변경한 경우
	        	        # 주사용자의 호출부호가 HL5KY인 경우
        	        	# 위의 조건뿐만 아니라 email은 관련 프로그램을 설치해야 작동함
	            		fi
			fi
		((idx++))
        	done
	fi
done
echo "---------------------------------------------------------------------------" >> "$logfile"
}
#----------- END OF restore_bm_address --------------------------------

extract_bm_list
# var??.txt에서 bm_address, original_bm_address를 뽑아서 각각 배열 만듬.

normal_ping_test
# 배열, bm_present_list의 요소에 있는 주소를 차례로 ping test 하여 bm_watchdog_status.txt에 저장

replace_bm_address
# bm_watchdog_status.txt에서 3회 이상 실패한 주소를 대체주소로 변경.

restore_ping_test
#  배열, original_present_list의 요소에 있는 주소를 차례로 ping test 하여 bm_watchdog_status.txt에 저장

restore_bm_address
# bm_watchdog_status.txt에서 5회 이상 성공한 주소를 복원함.



####### extract_bm_list 설명 ##################

#var${user}.txt에서 bm_address를 뽑아서 
#중복되지 않게 배열을 만들고 bm_present_list.txt로 만든다.
#마찬가지로 original_bm_address도 배열로 만들어 넣는다.


####### normal_ping_test 설명 #################

#var${user}에서 추출한 서버 리스트(bm_present_list)의 배열 요소를 차례로
#하나씩 ping 확인하여 결과값을 bm_watchdog_status.txt에 저장한다


####### replace_bm_address 설명 ###############

#for var${user}에서 추출한 서버 리스트(bm_present_list)의 배열 요소를 차례로 하나씩 확인
#|	if 특정 서버가 결과값인 bm_watchdog_status.txt에서 3회 이상 실패하면
#|	|	while DMRIds_host.txt에서 하나씩 대체주소 ping 확인- 모든 줄 확인
#|	|	|	if 대체주소의 ping이 성공하면 주소전환 시작
#|	|	|	|	while user to max_user에서 하나씩 do
#|	|	|	|	|	주소전환
#|	|	|	|	done
#|	|	|	|	break
#|	|	|	else
#|	|	|	|	실패 >> $logfile
#|	|	|	fi
#|	|	|	다음 라인으로 이동
#|	|	|	loop 한바퀴 돌면 다시 시작
#|	|	|	loop_count 조정
#|	|	done
#|	fi
#done
