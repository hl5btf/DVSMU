#!/bin/bash

#===================================
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2025/07/22"
#===================================

source /var/lib/dvswitch/dvs/var.txt

############################################
#  do_enable_gpio_uart
############################################
function do_enable_gpio_uart() {

# Remove serial console from cmdline.txt and add enable_uart to config.txt
sudo raspi-config nonint do_serial 2

# Check for existence of bluetooth and move it to the mini uart.
if sudo rfkill --noheadings --output TYPE | grep -q "bluetooth"; then
     if ! sudo grep -q "dtoverlay miniuart-bt" /boot/config.txt; then
         echo "dtoverlay miniuart-bt" | sudo tee -a /boot/config.txt
     fi
fi
}

############################################
#  do_config
############################################

function do_config() {

# Start of progress bar
{
# -----------------------------------------
let "complete=complete+20"
echo -e "$complete"

#-----------------------------------------------------------
update_var call_sign ${call_sign}
update_var dmr_id ${dmr_id}
update_var rpt_id ${rpt_id}
rpt_id_2=$(($rpt_id+10))
rpt_id_3=$(($rpt_id+20))
update_var rpt_id_2 ${rpt_id_2}
update_var rpt_id_3 ${rpt_id_3}
update_var module ${module}
update_var nxdn_id ${nxdn_id}
update_var usrp_port ${usrp_port}
#-----------------------------------------
let "complete=complete+20"
echo -e "$complete"
update_var bm_master ${bm_master}
update_var bm_address ${bm_address}
update_var bm_password ${bm_password}
update_var bm_port ${bm_port}
update_var ambe_option ${ambe_option}
update_var ambe_server ${ambe_server}
update_var ambe_rxport ${ambe_rxport}
update_var ambe_baud ${ambe_baud}

update_var rx_freq ${rx_freq}
update_var tx_freq ${tx_freq}
update_var pwr ${pwr}
update_var lat ${lat}
update_var lon ${lon}
update_var hgt ${hgt}
update_var lctn "${lctn}"
update_var desc "${desc}"
update_var url ${url}
#-----------------------------------------
let "complete=complete+10"
echo -e "$complete"


#-----------------------------------------------------------

do_KR() {
        sudo ${DVS}temp_msg.sh -y

        sudo \mv -f ${AB}dvsm.macro ${AB}dvsm.basic
        sudo \cp -f ${adv}dvsm.* ${AB}
        sudo chmod +x ${AB}dvsm.sh
        if [ -d ${adv}${LN} ]; then
                sudo \cp -f ${adv}${LN}/*.* ${AB}
        fi

        update_var dmrplus_address ipsc.dvham.com
        update_var dmrplus_password PASSWORD
        update_var dmrplus_port 55555
}

do_tgdb_file_copy() {
	if [ -d ${tgdb}${LN} ]; then
        	sudo \cp -f ${tgdb}${LN}/* ${tgdb}
	else
        	sudo \cp -f ${tgdb}EN/* ${tgdb}
	fi
}

do_AB_ini_audio_edit() {
        file="${AB}Analog_Bridge.ini"
        sudo sed -i -e "/^usrpAudio/ c usrpAudio = AUDIO_USE_GAIN              ; Digital -> Analog (AUDIO_UNITY, AUDIO_USE_GAIN, AUDIO_USE_AGC)" $file
        sudo sed -i -e "/^usrpGain/ c usrpGain = ${usrpGain}                         ; Gain factor when usrpAudio = AUDIO_USE_GAIN (0.0 to 5.0) (1.0 = AUDIO_UNITY)" $file
        sudo sed -i -e "/^tlvAudio/ c tlvAudio = AUDIO_USE_GAIN               ; Analog -> Digital (AUDIO_UNITY, AUDIO_USE_GAIN, AUDIO_BPF)" $file
        sudo sed -i -e "/^tlvGain/ c tlvGain = ${txgain_dmr}                          ; Gain factor when tlvAudio = AUDIO_USE_GAIN (0.0 to 5.0) (1.0 = AUDIO_UNITY)" $file
}
#-----------------------------------------------------------

if [ "${first_time_instl}" = "1" ]; then
		if [ ${dmr_id:0:3} = 450 ] || [ "${macro_lan}" = "KOR" ]; then
                LN=KR
				do_KR
                do_tgdb_file_copy
                do_AB_ini_audio_edit
        else
                LN=EN
		do_tgdb_file_copy
#                do_AB_ini_audio_edit
        fi


	# update DMR server list on the macro, adv_dmr.txt
	${DVS}adnl_dmr.sh advdmr_return

	update_var first_time_instl 73
fi

#-----------------------------------------------------------
let "complete=complete+20"
echo -e "$complete"

file=${AB}Analog_Bridge.ini
	sudo sed -i -e "/^useEmulator =/ c useEmulator = true                      ; Use the MD380 AMBE emulator for AMBE72 (DMR/YSFN/NXDN)" $file
	sudo sed -i -e "/^gatewayDmrId =/ c gatewayDmrId = ${dmr_id}                  ; ID to use when transmitting from Analog_Bridge 7 digit ID" $file
	sudo sed -i -e "/^repeaterID =/ c repeaterID = ${rpt_id}                  ; ID of source repeater 7 digit ID plus 2 digit SSID" $file
	if [ x${usrp_port} != x ]; then
		sudo sed -i -e "/Transmit USRP/ c txPort = ${usrp_port}                          ; Transmit USRP frames on this port" $file
		sudo sed -i -e "/Listen for USRP/ c rxPort = ${usrp_port}                          ; Listen for USRP frames on this port" $file
	fi
#-----------------------------------------------------------
#-----------------------------------------

file=${MB}MMDVM_Bridge.ini
	sudo sed -i -e "/^Callsign=/ c Callsign=${call_sign}" ${file}
	sudo sed -i -e "/^Enable=/ c Enable=1" $file
	sudo sed -i -e "/^Module=/ c Module=${module}" ${file}
	$update_ini $file "DMR Network" Address ${bm_address}
	$update_ini $file "DMR Network" Password ${bm_password}
	$update_ini $file "DMR Network" Port ${bm_port}
        #sudo sed -i -e "/^Address=/ c Address=${bm_address}" ${file}
        #sudo sed -i -e "/^Password=/ c Password=${bm_password}" ${file}
	General=$(grep -n "\[General" ${MB}MMDVM_Bridge.ini | cut -d':' -f1)
	id_line=`expr $General + 2`
	sudo sed -i -e "${id_line}s/.*/Id=${rpt_id}/" ${file}

	NXDN=$(grep -n "\[NXDN\]" ${MB}MMDVM_Bridge.ini | cut -d':' -f1)
	id_line=`expr $NXDN + 3`
        sudo sed -i -e "${id_line}s/.*/Id=${nxdn_id}/" ${file}
#-----------------------------------------
let "complete=complete+10"
echo -e "$complete"

# update default_DMR_server according to var.txt, specially needed on the reconfiguration of <initial configuration>
sudo ${DVS}adnl_dmr.sh MBini_return > /dev/null


file=${MB}MMDVM_Bridge.ini

function edit_info() {
if [ "$2" != "" ]; then
        sudo sed -i -e "/^$1=/ c $1=$2" ${file}
fi
}

edit_info RXFrequency ${rx_freq}
edit_info TXFrequency ${tx_freq}
edit_info Power ${pwr}
edit_info Latitude ${lat}
edit_info Longitude ${lon}
edit_info Height ${hgt}
edit_info Location "${lctn}"
edit_info Description "${desc}"
edit_info URL ${url}


file=/opt/MMDVM_Bridge/DVSwitch.ini
file_var=/var/lib/dvswitch/dvs/var.txt

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
#                if [[ "$dvs_TA" == *"%callsign"* || -z "$dvs_TA" ]]; then
#                        tag=talkerAlias; value="dvsMultiUser by HL5KY"
#                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var
#
#                        sudo systemctl stop mmdvm_bridge > /dev/null 2>&1
#                        $update_ini $file DMR talkerAlias "dvsMultiUser by HL5KY"
#                        sudo systemctl start mmdvm_bridge > /dev/null 2>&1
#
#                # dvs_TA가 공란이 아니면
#                elif [[ -n "$dvs_TA" ]]; then
				if [[ -n "$dvs_TA" ]]; then
                        tag=talkerAlias; value="$dvs_TA"
                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var
                fi
        fi

#-----------------------------------------------------------
#-----------------------------------------
let "complete=complete+10"
echo -e "$complete"

file=/opt/NXDNGateway/NXDNGateway.ini
        sudo sed -i -e "/^Callsign=/ c Callsign=${call_sign}" ${file}
#-----------------------------------------------------------
file=/opt/P25Gateway/P25Gateway.ini
        sudo sed -i -e "/^Callsign=/ c Callsign=${call_sign}" ${file}
#-----------------------------------------------------------
echo "      -----------------------------------------"
ysf="/opt/YSFGateway/"
file=/opt/YSFGateway/YSFGateway.ini
        sudo sed -i -e "/^Callsign=/ c Callsign=${call_sign}" ${file}
	sudo sed -i -e "/^Id=/ c Id=${rpt_id}" $file
#-----------------------------------------------------------
file=/opt/Quantar_Bridge/Quantar_Bridge.ini
        sudo sed -i -e "/^Address =/ c Address = 127.0.0.1             ; Address to send IMBE TLV frames to (export)" ${file}
#-----------------------------------------------------------
#-----------------------------------------

file=/etc/ircddbgateway
        sudo sed -i -e "/^gatewayCallsign=/ c gatewayCallsign=${call_sign}" ${file}
        sudo sed -i -e "/^repeaterCall1=/ c repeaterCall1=${call_sign}" ${file}
	sudo sed -i -e "/^repeaterBand1=/ c repeaterBand1=${module}" ${file}
        sudo sed -i -e "/^ircddbUsername=/ c ircddbUsername=${call_sign}" ${file}
        sudo sed -i -e "/^ircddbPassword=/ c ircddbPassword=${call_sign}" ${file}
        sudo sed -i -e "/^dplusEnabled=/ c dplusEnabled=1" $file
        sudo sed -i -e "/^dplusLogin=/ c dplusLogin=${call_sign}" ${file}
        sudo sed -i -e "/^language=/ c language=0" $file
        sudo sed -i -e "/^logEnabled=/ c logEnabled=1" $file
#	sudo sed -i -e "/^remoteEnabled=/ c remoteEnabled=1" $file
	sudo sed -i -e "/^remotePassword=/ c remotePassword=${rpt_id}" $file
#	sudo sed -i -e "/^remotePort=/ c remotePort=54321" $file
#-----------------------------------------------------------
#-----------------------------------------

#file=/var/www/html/include/config.php
#	sudo sed -i -e "/^define(\"ABINFO\"/ c define(\"ABINFO\", \"${usrp_port}\");" $file

file="/root/.Remote Control"
	sudo sed -i -e "/^password/ c password=${rpt_id}" "$file"

let "complete=complete+10"
echo -e "$complete"

# AMBE
ambe_add="address = ${ambe_server}               ; IP address of AMBEServer"
ambe_add_default="address = 127.0.0.1                 ; IP address of AMBEServer"
ambe_port="rxPort = ${ambe_rxport}                       ; Port of AMBEServer"
dvce_usb="address = /dev/ttyUSB0              ; Device of DV3000U on this machine"
dvce_ama="address = /dev/ttyAMA0                ; Device of DV3000U on this machine"
baud="baud = ${ambe_baud}                       ; Baud rate of the dongle (230400 or 460800)"
serial="serial = true                       ; Use serial=true for direct connect or serial=false for AMBEServer"

file=${AB}Analog_Bridge.ini

if [ "$ambe_option" = "1" ]; then
          sudo sed -i -e "/IP address of AMBE/ c $ambe_add" $file
          sudo sed -i -e "/Port of AMBE/ c $ambe_port" $file
          sudo sed -i -e "/Device of DV3000/ c ; $dvce_usb" $file
          sudo sed -i -e "/Baud rate/ c ; $baud" $file
          sudo sed -i -e "/Use serial/ c ; $serial" $file

elif [ "$ambe_option" = "2" ]; then
          sudo sed -i -e "/IP address of AMBE/ c ; $ambe_add_default" $file
          sudo sed -i -e "/Port of AMBE/ c ; $ambe_port" $file
          sudo sed -i -e "/Device of DV3000/ c $dvce_usb" $file
          sudo sed -i -e "/Baud rate/ c $baud" $file
          sudo sed -i -e "/Use serial/ c $serial" $file

elif [ "$ambe_option" = "3" ]; then
          sudo sed -i -e "/IP address of AMBE/ c ; $ambe_add_default" $file
          sudo sed -i -e "/Port of AMBE/ c ; $ambe_port" $file
          sudo sed -i -e "/Device of DV3000/ c $dvce_ama" $file
          sudo sed -i -e "/Baud rate/ c $baud" $file
          sudo sed -i -e "/Use serial/ c $serial" $file

elif [ "$ambe_option" = "4" ]; then
          sudo sed -i -e "/IP address of AMBE/ c ; $ambe_add_default" $file
          sudo sed -i -e "/Port of AMBE/ c ; $ambe_port" $file
          sudo sed -i -e "/Device of DV3000/ c ; $dvce_usb" $file
          sudo sed -i -e "/Baud rate/ c ; $baud" $file
          sudo sed -i -e "/Use serial/ c ; $serial" $file
fi

#-----------------------------------------

# variable ${services} is in func.txt
sudo systemctl restart $services > /dev/null 2>&1
#-----------------------------------------

} |whiptail --title " 주사용자 설정 진행 중" --gauge "잠깐만 기다리세요... (Please Wait...)" 6 60 0

#-----------------------------------------

if [ "$1" = "return" ]; then clear; exit 0;

elif [ "$ambe_option" = "3" ]; then
do_enable_gpio_uart

whiptail --msgbox "\
$sp11 주사용자 설정 완료.

$sp11 주사용자의 세부설정은 dvs에서 가능합니다.

$sp11 GPIO형식의 AMBE는 리부팅이 필요합니다.

$sp11 (Main user configuration finished)
$sp11 (GPIO-type AMBE needs Reboot)

$sp11 $T192

" 16 70 1
clear; sudo reboot; exit 0


else
whiptail --msgbox "\
$sp11 주사용자 설정 완료.

$sp11 주사용자의 세부설정은 dvs에서 가능합니다.

$sp11 (Main user configuration finished)

$sp11 $T004

" 12 70 1
clear; ${DVS}dvsmu M; exit 0
fi

}

###############################################################
# Function main_user_input
###############################################################
function main_user_input() {

source /var/lib/dvswitch/dvs/var.txt

user_array="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40"


clear

# 파일이 있고, 콜싸인이 비어있지 않으면
if [ -e /var/lib/dvswitch/dvs/var.txt ] && [ x${call_sign} != x ]; then
if (whiptail --title " 주사용자 설정 변경 " --yesno "\
$sp05 주사용자의 설정을 변경합니다.

$sp05 (EDIT configuration of Main user)

$sp05 $T005
" 12 65); then :
        else ${DVS}dvsmu M; exit 0
fi
fi

# USRP Port 중복 확인 루틴 이후에 다시 source를 변경하므로, 입력 변수를 call_sign_in 등과 같이 변경해서 사용함

call_sign_in=$(whiptail --title " 입력 " --inputbox "호출부호? (대소문자 구분없음)  (Callsign)" 10 60 ${call_sign} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
#

call_sign_in=`echo ${call_sign_in} | tr '[a-z]' '[A-Z]'`

if [ x${dmr_id} != x ]; then
dmr_id_old=${dmr_id}
else dmr_id_old=none
fi

dmr_id_in=$(whiptail --title " 입력 " --inputbox "CCS7/DMR ID ?" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
#

until [ ${#dmr_id_in} = 7 ]; do
dmr_id_in=$(whiptail --title " 입력 " --inputbox "CCS7/DMR ID ?  (7자리 숫자)  (7 digits)" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
done

if [ "${dmr_id_old}" = ${dmr_id_in} ]; then
rpt_id_in=$(whiptail --title " 입력 " --inputbox "CCS7/DMR ID + 2자리숫자 (00 ~99) (+ 2 digits) ?" 10 60 ${rpt_id} 3>&1 1>&2 2>&3)
else
rpt_id_in=$(whiptail --title " 입력 " --inputbox "CCS7/DMR ID + 2자리숫자 (00 ~99) (+ 2 digits) ?" 10 60 ${dmr_id_in} 3>&1 1>&2 2>&3)
fi
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

until [ ${#rpt_id_in} = 9 ]; do
if [ ${dmr_id_old} = ${dmr_id} ]; then
rpt_id_in=$(whiptail --title " 입력 " --inputbox "CCS7/DMR ID + 2자리숫자 (합계9자리)  (9 digits)" 10 70 ${rpt_id} 3>&1 1>&2 2>&3)
else
rpt_id_in=$(whiptail --title " 입력 " --inputbox "CCS7/DMR ID + 2자리숫자 (합계9자리)  (9 digits)" 10 70 ${dmr_id} 3>&1 1>&2 2>&3)
fi
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
done

#--------------USRP PORT 입력 중복 확인 시작 부분 -------------------------------

usrp_port_in=$(whiptail --title " 입력 " --inputbox "USRP Port? ( 50000 ~ 55000 )" 10 60 ${usrp_port} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
#

ar_status=$(systemctl is-active analog_reflector)
if [ $ar_status = "active" ]; then
        file=/opt/Analog_Reflector/Analog_Reflector.json
        usrp_port_ar=$(sed -n -e '/mobilePort/p' $file | sed 's/[^0-9]//g')
        declare usrp_port_chk=$usrp_port_ar
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check_ar=no
        else
        declare port_check_ar=ok
        fi
fi

user=$user_array

for user in $user; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ]; then

        source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
        declare usrp_port_chk=$usrp_port
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check=no; break
        fi
fi
declare port_check=ok
done

#-------------------------------

until [ $usrp_port_in != "" ] && [ "$port_check_ar" != no ] && [ "$port_check" != no ]; do

usrp_port_in=$(whiptail --title " 입력 " --inputbox "Port $usrp_port_in 다른 사용자와 중복됨. 다시 입력.  (Port NO conflicts)" 10 60 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

ar_status=$(systemctl is-active analog_reflector)
if [ $ar_status = "active" ]; then
        file=/opt/Analog_Reflector/Analog_Reflector.json
        usrp_port_ar=$(sed -n -e '/mobilePort/p' $file | sed 's/[^0-9]//g')
        declare usrp_port_chk=$usrp_port_ar
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check_ar=no
        else
        declare port_check_ar=ok
        fi
fi

user=$user_array

for user in $user; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ]; then
        source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
        declare usrp_port_chk=$usrp_port
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check=no; break
        fi
fi
declare port_check=ok
done

done

#----------- USRP PORT 입력 중복 확인 끝 부분-----------------------

source /var/lib/dvswitch/dvs/var.txt

# 입력변수를 다시 바꿈
call_sign=$call_sign_in; rpt_id=$rpt_id_in; dmr_id=$dmr_id_in; usrp_port=$usrp_port_in


if [ x${module} = x ]; then
        if [ ${dmr_id:0:3} = 450 -o "${LN}" = "KR" ]; then
        module=S
        else module=B
        fi
fi

module=$(whiptail --title " 입력 " --inputbox "Dstar module ? (A~Z) ? " 10 60 ${module} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
#

nxdn_id=$(whiptail --title " 입력 " --inputbox "NXDN ID  (없으면 ENTER)  (if none, press ENTER)" 10 60 ${nxdn_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
#

rx_MHz=${rx_freq:0:3}"."${rx_freq:3:4}

rx_MHz=$(whiptail --title " 입력 " --inputbox "송수신 주파수(xxx.xxxx MHz)" 10 60 ${rx_MHz} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

until [ ${#rx_MHz} = 8 ]; do
rx_MHz=$(whiptail --title " 입력 " --inputbox "송수신 주파파수(xxx.xxxx MHz, 소수점 4자리)" 10 60 ${rx_MHz} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
done

rx_freq=${rx_MHz:0:3}${rx_MHz:4:4}"00"
tx_freq=${rx_MHz:0:3}${rx_MHz:4:4}"00"


#------- Create bm.list from DMR_Hotsts.txt ----------------------------------------------

sudo \cp -f ${DATA}bm.list ${DATA}bm.list_old > /dev/null 2>&1

# get the records starting "BM_" from DMR_Hosts.txt and create bm.list_1
sudo grep -i -e "^BM_" ${dir_host}DMR_Hosts.txt | sudo tee ${DATA}bm.list_1 > /dev/null 2>&1

# cut the first column from bm.list_1
sudo cut -f1 ${DATA}bm.list_1 | sudo tee ${DATA}bm.list_2 > /dev/null 2>&1

# add a new line "===Type_in===" in the last line of bm.list
#sudo bash -c 'echo ===Type_in=== >> /var/lib/dvswitch/dvs/bm.list' > /dev/null 2>&1

# number all the lines
sudo nl ${DATA}bm.list_2 | sudo tee ${DATA}bm.list > /dev/null 2>&1

# verify bm.list is valid
file=${DATA}bm.list
if [[ -z `sudo grep "BM_" $file` ]]; then
sudo \cp -f ${DATA}bm.list_old ${DATA}bm.list > /dev/null 2>&1
fi

sudo rm ${DATA}bm.list_* > /dev/null 2>&1

#------- Create bm.list from DMR_Hotsts.txt ----------------------------------------------

value=$(cat ${DATA}bm.list)
num=$(whiptail --title "Local Brandmeister Master Server" --menu "\
\n
      $T163
" 30 42 20 ${value} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

sel_line=$(sudo awk '$1 == '"$num"' { print $2 }' ${DATA}bm.list)

bm_master=
bm_address=$(awk '$1 == "'${sel_line}'" { print $3 }' ${dir_host}DMR_Hosts.txt)
# bm_password=$(awk '$1 == "'${sel_line}'" { print $4 }' ${dir_host}DMR_Hosts.txt)
bm_port=$(awk '$1 == "'${sel_line}'" { print $5 }' ${dir_host}DMR_Hosts.txt)

bm_password=$(whiptail --title " 입력 " --inputbox "브랜드마이스터 비밀번호  (BM SelfCare password)" 10 60 ${bm_password} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

#------- AMBE -----------------------------------------------------------------------------

OPTION=$(whiptail --title " 하드웨어 보코더 (AMBE) " --menu "\
\n
" 13 80 4 \
"1 AMBE Server  " "External AMBE Server e.g., ZumAMBE Server" \
"2 USB Type AMBE  " "ThumbDV, DVstick" \
"3 GPIO type AMBE  " "DV3000 or PAMBE Board" \
"4 하드웨어 보코더 없음  "  "No Hardware Vocoder" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

case "$OPTION" in
1\ *)ambe_option="1" ;;
2\ *)ambe_option="2" ;;
3\ *)ambe_option="3" ;;
4\ *)ambe_option="4" ;;
esac

if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi
#----------------------------------------------------------------------------------------------------------------------
if [ $ambe_option = "1" ]; then
        ambe_server=$(whiptail --title " IP address of AMBEServer " --inputbox "IP or DDNS address ?" 8 50 ${ambe_server} 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ${DVS}dvsmu M exit 0; fi

        ambe_rxport=$(whiptail --title " Port of AMBEServer " --inputbox "Port (UDP) ?" 8 50 ${ambe_rxport} 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ${DVS}dvsmu M exit 0; fi

elif [ $ambe_option = "2" ]; then
        ambe_baud=$(whiptail --title " Baudrate of ThumbDV or DVstick " --inputbox "Baudrate ? [460800 (Old ver: 230400)]" 8 50 ${ambe_baud} 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ${DVS}dvsmu M exit 0; fi

elif [ $ambe_option = "3" ]; then
        ambe_baud=$(whiptail --title " Baudrate of AMBE Board " --inputbox "Baudrate ? [460800 (Old ver: 230400)]" 8 50 ${ambe_baud} 3>&1 1>&2 2>&3)
        if [ $? != 0 ]; then ${DVS}dvsmu M exit 0; fi

elif [ $ambe_option = "4" ]; then :

fi

#----------------------------------------------------------------------------------------------------------------------

pwr=$(whiptail --title " 입력 " --inputbox "출력 (Power)" 10 60 ${pwr} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

lat=$(whiptail --title " 입력 " --inputbox "위도 Latitude (xxx.xxxx OR -xxx.xxxx)" 10 60 -- ${lat} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

lon=$(whiptail --title " 입력 " --inputbox "경도 Longitude  (xxx.xxxx OR -xxx.xxxx)" 10 60 -- ${lon} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

hgt=$(whiptail --title " 입력 " --inputbox "지표고 (Altitude)" 10 60 ${hgt} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

lctn=$(whiptail --title " 입력 " --inputbox "위치 (Location)" 10 60 "${lctn}" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

desc=$(whiptail --title " 입력 " --inputbox "설명 (Description)" 10 60 "${desc}" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

url=$(whiptail --title " 입력 " --inputbox "URL" 10 60 ${url} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi


sel=$(whiptail --title " DVSM 매크로 언어 설정 " --menu "\

              DVSM 매크로 언어
              DVSM Macro Language
\n
" 12 55 2 \
"1" "한글(Korean)" \
"2" "영어(English)" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu M; exit 0; fi

case $sel in
1)
macro_lan=KOR ;;
2)
macro_lan=ENG ;;
esac

#-----------------------------------------------------------
if (whiptail --title " 입력완료 " --yesno "\
$sp15 입력 완료.

$sp15 입력된 내용으로 설정하시겠습니까?

$sp15 (Input finished, start configuring)

$sp15 $T005
" 14 70);
    then
        clear
        do_config
    else ${DVS}dvsmu M; exit 0
fi
#-----------------------------------------------------------
}

############################################
#  MAIN SCRIPT
############################################


if [ "$1" = "return" ]; then
        clear
        do_config return
fi

main_user_input

do_config
