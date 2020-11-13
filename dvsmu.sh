#!/bin/bash

#source /var/lib/dvswitch/dvs/var.txt

###############################################################
# Function update_DV3000
###############################################################
function update_DV3000() {

# usage $1:1st keyword for search, $2:2nd keyword for search or " ", $3:value, $4:cmnt_out for comment out or n/a, $5:USER_NO
# ex1) update_DV3000 address AMBE 127.0.0.1 cmnt_out $USER_NO
# ex2) update_DV3000 rxPort AMBE 2460 cmnt_out $USER_NO
# ex3) update_DV3000 address dev "\/dev\/ttyUSB0" cmnt_out $USER_NO
# ex4) update_DV3000 baud Baud 460800 cmnt_out $USER_NO
# ex5) update_DV3000 serial serial true cmnt_out $USER_NO

source /var/lib/dvswitch/dvs/var$5.txt

USER_NO=$5

file=${AB}Analog_Bridge.ini
sec=DV3000

line_contents=$(sed  -n "/^\[$sec\]/,/^\[/ p" "$file" | sed -n "/$1/p" | sed -n "/$2/p")
if [ "${line_contents:0:1}" = ";" ]; then line_contents=${line_contents:1}; fi
if [ "${line_contents:0:1}" = " " ]; then line_contents=${line_contents:1}; fi

idx=$(expr index "$line_contents" ";")
rmks="${line_contents#*;}"
row_no=$(sudo grep -n "$line_contents" $file | cut -d: -f1)

var1=$1; var3=$3
var3=$(echo $var3 | sudo sed "s/\//""/g")
leng1=${#var1}; leng3=${#var3}

sp=$(($idx - $leng1 - $leng3 - 6))
varname=sp${sp}
sp=${!varname}

if [ "$4" = cmnt_out ]; then
new_line="; $1 = $3 $sp ;$rmks"
else
new_line="$1 = $3 $sp ;$rmks"
fi

sudo sed -i "${row_no}s/.*/$new_line/" $file
}

###############################################################
# Function update_data
###############################################################
function update_data() {
source /var/lib/dvswitch/dvs/var$1.txt
USER_NO=$1

if [ ${USER_NO:0:1} = 0 ]; then
	USER_NO_NO=${USER_NO:1:1}
	else USER_NO_NO=$USER_NO
fi

file=/opt/user$USER_NO/dvswitch.sh
	sudo sed -i "s/\/opt\/MMDVM_Bridge\//\/opt\/user$USER_NO\//g" $file
	sudo sed -i "s/\/opt\/Analog_Bridge\//\/opt\/user$USER_NO\//g" $file

file=/opt/user$USER_NO/Analog_Bridge.ini
	$update_ini $file AMBE_AUDIO gatewayDmrId ${dmr_id}
	$update_ini $file AMBE_AUDIO repeaterID ${rpt_id}
	declare txport=$(($USER_NO_NO+31300))
	declare rxport=$(($USER_NO_NO+31000))
	$update_ini $file AMBE_AUDIO txPort $txport
	$update_ini $file AMBE_AUDIO rxPort $rxport
	$update_ini $file USRP txPort $usrp_port
	$update_ini $file USRP rxPort $usrp_port
	declare emu_port=$(($USER_NO_NO+2470))
	$update_ini $file GENERAL emulatorAddress 127.0.0.1:$emu_port
	update_DV3000 address AMBE 127.0.0.1 cmnt_out $USER_NO
	update_DV3000 rxPort AMBE 2460 cmnt_out $USER_NO
	update_DV3000 address dev "\/dev\/ttyUSB0" cmnt_out $USER_NO
	update_DV3000 baud Baud 460800 cmnt_out $USER_NO
	update_DV3000 serial serial true cmnt_out $USER_NO

source /var/lib/dvswitch/dvs/var$1.txt
USER_NO=$1

file=/opt/user$USER_NO/MMDVM_Bridge.ini
	$update_ini $file General Callsign ${call_sign}
	$update_ini $file General Id ${rpt_id}
	$update_ini $file "DMR Network" Address ${bm_address}
	$update_ini $file "DMR Network" Password ${bm_password}
	$update_ini $file "DMR Network" Port ${bm_port}
	$update_ini $file Log FileRoot MMDVM_Bridge$USER_NO
	sudo sed -i "s/Enable=1/Enable=0/g" $file
	$update_ini $file DMR Enable 1
	$update_ini $file "DMR Network" Enable 1
	sudo sed -i "s/Local=62032/# Local=62032/g" $file
	$update_ini $file Info RXFrequency ${rx_freq}
	$update_ini $file Info TXFrequency ${tx_freq}
	$update_ini $file Info Power ${pwr}
	$update_ini $file Info Latitude ${lat}
	$update_ini $file Info Longitude ${lon}
	$update_ini $file Info Height ${hgt}
	$update_ini $file Info Location "${lctn}"
	$update_ini $file Info Description "${desc}"
	sudo sed -i -e "/^URL/ c URL=https:\/\/www.qrz.com\/db\/${call_sign}" $file

file=/opt/user$USER_NO/DVSwitch.ini
        $update_ini $file DMR talkerAlias ${call_sign}
        declare txport=$(($USER_NO_NO+31000))
        declare rxport=$(($USER_NO_NO+31300))
        $update_ini $file DMR txPort $txport
        $update_ini $file DMR rxPort $rxport

sudo systemctl enable mmdvm_bridge$USER_NO > /dev/null 2>&1
sudo systemctl enable analog_bridge$USER_NO > /dev/null 2>&1
sudo systemctl enable md380-emu$USER_NO > /dev/null 2>&1

sudo systemctl start mmdvm_bridge$USER_NO > /dev/null 2>&1
sudo systemctl start analog_bridge$USER_NO > /dev/null 2>&1
sudo systemctl start md380-emu$USER_NO > /dev/null 2>&1

if [ "$2" = "return" ]; then :

else

clear
whiptail --msgbox "\

$sp10 설정이 완료되었습니다.
" 9 50 1

${DVS}dvsmu; exit 0

fi
}
###############################################################
# Function user_input
###############################################################
function user_input() {
source /var/lib/dvswitch/dvs/var$1.txt

USER_NO=$1

if [ ${USER_NO:0:1} = 0 ]; then
        USER_NO_NO=${USER_NO:1:1}
        else USER_NO_NO=$USER_NO
fi

call_sign=$(whiptail --title "$T009" --inputbox "$T160" 10 60 ${call_sign} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#

call_sign=`echo ${call_sign} | tr '[a-z]' '[A-Z]'`

if [ x${dmr_id} != x ]; then
dmr_id_old=${dmr_id}
else dmr_id_old=none
fi

dmr_id=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID ?" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#

until [ ${#dmr_id} = 7 ]; do
dmr_id=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID ?  ($T165)" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
done


if [ ${dmr_id_old} = ${dmr_id} ]; then
rpt_id_temp=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 (00 ~99) ?" 10 60 ${rpt_id} 3>&1 1>&2 2>&3)
else
rpt_id_temp=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 (00 ~99) ?" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
fi
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

until [ ${#rpt_id_temp} = 9 ]; do
if [ ${dmr_id_old} = ${dmr_id} ]; then
rpt_id_temp=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 ($T167)" 10 70 ${rpt_id} 3>&1 1>&2 2>&3)
else
rpt_id_temp=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 ($T167)" 10 70 ${dmr_id} 3>&1 1>&2 2>&3)
fi
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
done

rpt_id=${rpt_id_temp}


usrp_port=$(whiptail --title "$T009" --inputbox "$T410" 10 60 ${usrp_port} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#


rx_MHz=${rx_freq:0:3}"."${rx_freq:3:4}

if [[ $T213 =~ RXFrequency ]]; then T213=$T213; else T213="RXFrequency : $T213"; fi
rx_MHz=$(whiptail --title " $T009 " --inputbox "$T213" 10 60 ${rx_MHz} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi


if [[ $T216 =~ RXFrequency ]]; then T216=$T216; else T216="RXFrequency : $T216"; fi
until [ ${#rx_MHz} = 8 ]; do
rx_MHz=$(whiptail --title " $T009 " --inputbox "$T216" 10 60 ${rx_MHz} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
done

rx_freq=${rx_MHz:0:3}${rx_MHz:4:4}"00"

tx_MHz=${tx_freq:0:3}"."${tx_freq:3:4}

if [[ $T214 =~ TXFrequency ]]; then T214=$T214; else T214="TXFrequency : $T214"; fi
tx_MHz=$(whiptail --title " $T009 " --inputbox "$T214" 10 60 ${tx_MHz} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi


if [[ $T217 =~ TXFrequency ]]; then T217=$T217; else T217="TXFrequency : $T217"; fi
until [ ${#tx_MHz} = 8 ]; do
tx_MHz=$(whiptail --title " $T009 " --inputbox "$T217" 10 60 ${tx_MHz} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
done

tx_freq=${tx_MHz:0:3}${tx_MHz:4:4}"00"

if [[ $T218 =~ Latitude ]]; then T218=$T218; else T218="Latitude : $T218"; fi
lat=$(whiptail --title " $T009 " --inputbox "$T218" 10 60 -- ${lat} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

if [[ $T219 =~ Longitude ]]; then T219=$T219; else T219="Longitude : $T219"; fi
lon=$(whiptail --title " $T009 " --inputbox "$T219" 10 60 -- ${lon} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

if [[ $T222 =~ Location ]]; then T222=$T222; else T222="Location : $T222"; fi
lctn=$(whiptail --title " $T009 " --inputbox "$T222" 10 60 "${lctn}" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

if [[ $T223 =~ Description ]]; then T223=$T223; else T223="Description : $T223"; fi
desc=$(whiptail --title " $T009 " --inputbox "$T223" 10 60 "${desc}" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

#-----------------------------------------------------------
if (whiptail --title " 입력완료 " --yesno "\
$sp15 사용자 정보의 입력이 완료되었습니다.
$sp15 입력된 내용으로 설정하시겠습니까?

$sp15 $T005
" 11 70);
	then :
	else ${DVS}dvsmu; exit 0
fi
#-----------------------------------------------------------

TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60

sudo sed -i "s/USER_NO/${USER_NO}/g" /var/lib/dvswitch/dvs/var$USER_NO.txt > /dev/null 2>&1

sudo systemctl stop mmdvm_bridge$USER_NO > /dev/null 2>&1
sudo systemctl stop analog_bridge$USER_NO > /dev/null 2>&1
sudo systemctl stop md380-emu$USER_NO > /dev/null 2>&1

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

# update_var bm_master South_Korea_4501
update_var bm_address bm.dv.or.kr
update_var bm_password passw0rd
update_var bm_port 62031

if [ ${dmr_id:0:3} = 450  ]; then
	update_var dmrplus_address ipsc.dvham.com
	update_var dmrplus_password PASSWORD
	update_var dmrplus_port 55555
fi

update_var rx_freq ${rx_freq}
update_var tx_freq ${tx_freq}
update_var pwr 0
update_var lat ${lat}
update_var lon ${lon}
update_var hgt 0
update_var lctn "${lctn}"
update_var desc "${desc}"


sudo mkdir /opt/user$1 > /dev/null 2>&1
sudo cp /opt/Analog_Bridge/* /opt/user$1
sudo cp /opt/MMDVM_Bridge/* /opt/user$1
sudo cp /opt/md380-emu/* /opt/user$1

sudo \cp -f ${adv}user00/dvsm.* /opt/user$1

file=/opt/user$1/dvsm.macro
        sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/opt/user$1/dvsm.adv
        sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/opt/user$1/dvsm.basic
        sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/opt/user$1/dvsm.sh
        sudo sed -i "s/USER_NO/$USER_NO/g" $file


sudo cp ${DATA}analog_bridge00.service /lib/systemd/system/analog_bridge$1.service
sudo cp ${DATA}mmdvm_bridge00.service /lib/systemd/system/mmdvm_bridge$1.service
sudo cp ${DATA}md380-emu00.service /lib/systemd/system/md380-emu$1.service

sudo mkdir /var/log/dvswitch/user$USER_NO

file=/lib/systemd/system/analog_bridge$USER_NO.service
	sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/lib/systemd/system/mmdvm_bridge$USER_NO.service
        sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/lib/systemd/system/md380-emu$USER_NO.service
	sudo sed -i "s/USER_NO/$USER_NO/g" $file
	declare emu_port=$(($USER_NO_NO+2470))
	sudo sed -i "s/2470/$emu_port/g" $file > /dev/null 2>&1
	sudo sed -i "s/2471/$emu_port/g" $file > /dev/null 2>&1

if [ ${dmr_id:0:3} = 450  ]; then
	sudo \cp -f ${adv}user00KR/*.* /opt/user$USER_NO
else
	sudo \cp -f ${adv}user00EN/*.* /opt/user$USER_NO
fi

sudo mkdir ${tgdb}user$USER_NO > /dev/null 2>&1
if [ ${dmr_id:0:3} = 450  ]; then
	sudo cp ${tgdb}KR/*.* ${tgdb}user$USER_NO
else
	sudo cp ${tgdb}EN/*.* ${tgdb}user$USER_NO
fi

update_data $USER_NO
}

###############################################################
# Function user_delete
###############################################################
function user_delete() {
clear

source /var/lib/dvswitch/dvs/var$1.txt > /dev/null 2>&1
USER_NO=$1

if (whiptail --title " 사용자 삭제 " --yesno "\
$sp12 User$USER_NO의 모든 내용을 삭제하시겠습니까?

$sp12 $T005
" 10 70);
then :
else ${DVS}dvsmu $USER_NO; exit 0
fi

if [ $? != 0 ]; then ${DVS}dvsmu $USER_NO; exit 0; fi

TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60

sudo systemctl stop mmdvm_bridge$USER_NO
sudo systemctl stop analog_bridge$USER_NO
sudo systemctl stop md380-emu$USER_NO

sudo systemctl disable mmdvm_bridge$USER_NO > /dev/null 2>&1
sudo systemctl disable analog_bridge$USER_NO > /dev/null 2>&1
sudo systemctl disable md380-emu$USER_NO > /dev/null 2>&1

sudo rm /opt/user$USER_NO/*
sudo rmdir /opt/user$USER_NO

sudo rm /lib/systemd/system/analog_bridge$USER_NO.service
sudo rm /lib/systemd/system/mmdvm_bridge$USER_NO.service
sudo rm /lib/systemd/system/md380-emu$USER_NO.service

sudo rm ${tgdb}user$USER_NO/*
sudo rmdir ${tgdb}user$USER_NO

sudo rm /var/log/dvswitch/user$USER_NO/*
sudo rmdir /var/log/dvswitch/user$USER_NO

sudo rm /var/log/mmdvm/MMDVM_Bridge$USER_NO*

sudo rm /var/lib/dvswitch/dvs/var$USER_NO.txt

source /var/lib/dvswitch/dvs/var.txt
${DVS}dvsmu
}

###############################################################
# Function upgrade
###############################################################
function upgrade() {
clear

source /var/lib/dvswitch/dvs/var.txt

if (whiptail --title " 업그레이드 " --yesno "\
$sp03 메인시스템의 업그레이드를 마친 후에 본 작업을 진행하여야 합니다.

$sp03 사용자당 약 20초의 시간이 걸립니다. 진행하시겠습니까?

$sp03 $T005
" 12 75);
        then :
        else ${DVS}dvsmu; exit 0
fi

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1

if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
        TERM=ansi whiptail --title "$T029" --infobox "  User${user} 업그레이드 및 설정중" 8 60

	sudo systemctl stop mmdvm_bridge${user} > /dev/null 2>&1
	sudo systemctl stop analog_bridge${user} > /dev/null 2>&1
	sudo systemctl stop md380-emu${user} > /dev/null 2>&1

	sudo \cp -f /opt/Analog_Bridge/* /opt/user${user}
	sudo \cp -f /opt/MMDVM_Bridge/* /opt/user${user}
	sudo \cp -f /opt/md380-emu/* /opt/user${user}

	sudo \cp -f ${adv}user00/dvsm.* /opt/user${user}

	file=/opt/user${user}/dvsm.macro
        	sudo sed -i "s/user00/user${user}/g" $file

	file=/opt/user${user}/dvsm.sh
        	sudo sed -i "s/USER_NO/${user}/g" $file

	if [ ${dmr_id:0:3} = 450  ]; then
		sudo \cp -f ${adv}user00KR/*.* /opt/user${user}
	else
		sudo \cp -f ${adv}user00EN/*.* /opt/user${user}
	fi

	update_data ${user} return
fi
done

clear
whiptail --msgbox "\

$sp04 업그레이드 및 설정이 완료되었습니다.
" 9 50 1

${DVS}dvsmu; exit 0
}

###############################################################
# Function restart
###############################################################
function restart() {
source /var/lib/dvswitch/dvs/var$1.txt > /dev/null 2>&1

USER_NO=$1

TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60

sudo systemctl restart mmdvm_bridge$USER_NO
sudo systemctl restart analog_bridge$USER_NO
sudo systemctl restart md380-emu$USER_NO

${DVS}dvsmu $USER_NO; exit 0
}

###############################################################
# Function main_user_config
###############################################################
function main_user_config() {

source /var/lib/dvswitch/dvs/var.txt

declare ext=${rpt_id:7:2}

file=/opt/MMDVM_Bridge/MMDVM_Bridge.ini

sec=D-Star; tag=Enable
line_contents=$($update_ini $file $sec $tag)
val=${line_contents##*=}; val=${val%%;*}; dstar=$(echo $val | sudo tr -d ' ')

sec="D-Star Network"; tag=Enable
line_contents=$($update_ini $file "$sec" $tag)
val=${line_contents##*=}; val=${val%%;*}; dstar_network=$(echo $val | sudo tr -d ' ')

if [ $dstar = 1 ] && [ $dstar_network = 1 ]; then
declare dstar_status="DSTAR 작동중"
else declare dstar_status="DSTAR 중지상태"
fi

#-------------------------------------------------------------
if [[ $T031 =~ $call_sign ]] && [ ${#call_sign} = 5 ];then

sel3=$(whiptail --title " Main User Configuration " --menu "\
\n
$sp05 $call_sign $dmr_id $ext $usrp_port  $dstar_status
-------------------------------------------------------
" 21 50 10 \
"1" "var.txt" \
"2" "Analog_Bridge.ini" \
"3" "MMDVM_Bridge.ini" \
"4" "DVSwitch.ini" \
"5" "dvsm.macro" \
"6" "dvsm.sh" \
"7" "서비스 재시작" \
"8" "DSTAR 활성화" \
"9" "DSTAR 비활성화" \
"10" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel3 in
1)
sudo nano /var/lib/dvswitch/dvs/var.txt; ${DVS}dvsmu M ;;
2)
sudo nano /opt/Analog_Bridge/Analog_Bridge.ini; ${DVS}dvsmu M ;;
3)
sudo nano /opt/MMDVM_Bridge/MMDVM_Bridge.ini; ${DVS}dvsmu M ;;
4)
sudo nano /opt/MMDVM_Bridge/DVSwitch.ini; ${DVS}dvsmu M ;;
5)
sudo nano /opt/Analog_Bridge/dvsm.macro; ${DVS}dvsmu M ;;
6)
sudo nano /opt/Analog_Bridge/dvsm.sh; ${DVS}dvsmu M ;;
7)
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60;
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
8)
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60;
$update_ini $file D-Star Enable 1; $update_ini $file "D-Star Network" Enable 1;
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
9)
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60;
$update_ini $file D-Star Enable 0; $update_ini $file "D-Star Network" Enable 0;
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
10)
${DVS}dvsmu; exit 0 ;;
esac

else

sel3=$(whiptail --title " Main User Configuration " --menu "\
\n
$sp05 $call_sign $dmr_id $ext $usrp_port  $dstar_status
-------------------------------------------------------
" 15 50 4 \
"1" "서비스 재시작" \
"2" "DSTAR 활성화" \
"3" "DSTAR 비활성화" \
"4" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel3 in
1)
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60;
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
2)
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60;
$update_ini $file D-Star Enable 1; $update_ini $file "D-Star Network" Enable 1;
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
3)
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60;
$update_ini $file D-Star Enable 0; $update_ini $file "D-Star Network" Enable 0;
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
4)
${DVS}dvsmu; exit 0 ;;
esac

fi
#-------------------------------------------------------------
exit 0
}

###############################################################
# Function user_config
###############################################################
function user_config() {

clear

source /var/lib/dvswitch/dvs/var.txt
        declare call_sign_M=$call_sign

source /var/lib/dvswitch/dvs/var$1.txt > /dev/null 2>&1

USER_NO=$1

if [ ! -e /var/lib/dvswitch/dvs/var$1.txt ] || [ x${call_sign} = x ]; then

	if (whiptail --title " 사용자 추가 " --yesno "\
$sp16 사용자를 추가하시겠습니까?

$sp16 $T005
" 10 70);
	then
		sudo \cp -f /var/lib/dvswitch/dvs/var00.txt /var/lib/dvswitch/dvs/var$1.txt
		sudo sed -i "s/USER_NO/$1/g" /var/lib/dvswitch/dvs/var$1.txt
		clear; user_input $1; exit 0
	else ${DVS}dvsmu; exit 0
	fi
fi

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi


declare ext=${rpt_id:7:2}

if [[ ! -z `grep "Advanced" /opt/user$USER_NO/dvsm.macro` ]]; then
macro_status="수정매크로사용중"
else macro_status="기본매크로사용중"
fi

#-------------------------------------------------------------
if [[ $T031 =~ $call_sign_M ]] && [ ${#call_sign_M} = 5 ];then

sel2=$(whiptail --title " User Configuration " --menu "\
\n
$sp02 User$USER_NO  $call_sign $dmr_id $ext $usrp_port $macro_status
-------------------------------------------------------
" 23 55 12 \
"1" "사용자 설정 변경" \
"2" "var${USER_NO}.txt" \
"3" "Analog_Bridge.ini" \
"4" "MMDVM_Bridge.ini" \
"5" "DVSwitch.ini" \
"6" "dvsm.macro" \
"7" "dvsm.sh" \
"8" "기본매크로로 변경" \
"9" "수정매크로로 변경" \
"10" "서비스 재시작" \
"11" "사용자 삭제" \
"12" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel2 in
1)
user_input $1 ;;
2)
sudo nano /var/lib/dvswitch/dvs/var$USER_NO.txt; ${DVS}dvsmu $USER_NO ;;
3)
sudo nano /opt/user$1/Analog_Bridge.ini; ${DVS}dvsmu $USER_NO ;;
4)
sudo nano /opt/user$1/MMDVM_Bridge.ini; ${DVS}dvsmu $USER_NO ;;
5)
sudo nano /opt/user$1/DVSwitch.ini; ${DVS}dvsmu $USER_NO ;;
6)
sudo nano /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
7)
sudo nano /opt/user$1/dvsm.sh; ${DVS}dvsmu $USER_NO ;;
8)
sudo \cp -f /opt/user$1/dvsm.basic /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
9)
sudo \cp -f /opt/user$1/dvsm.adv /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
10)
restart $USER_NO ;;
11)
user_delete $USER_NO ;;
12)
${DVS}dvsmu; exit 0 ;;
esac

else

sel2=$(whiptail --title " User Configuration " --menu "\
\n
$sp02 User$USER_NO  $call_sign $dmr_id $ext $usrp_port $macro_status
-------------------------------------------------------
" 17 55 6 \
"1" "사용자 설정 변경" \
"2" "서비스 재시작" \
"3" "기본매크로로 변경" \
"4" "수정매크로로 변경" \
"5" "사용자 삭제" \
"6" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel2 in
1)
user_input $1 ;;
2)
restart $USER_NO ;;
3)
sudo \cp -f /opt/user$1/dvsm.basic /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
4)
sudo \cp -f /opt/user$1/dvsm.adv /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
5)
user_delete $USER_NO ;;
6)
${DVS}dvsmu; exit 0 ;;
esac
fi
#-------------------------------------------------------------
exit 0
}

###############################################################
# MAIN SCRIPT
###############################################################
clear

USER_NO=$1

if [ "$USER_NO" = M ]; then main_user_config; fi

if [ x${USER_NO} != x ]; then user_config $USER_NO; fi

source /var/lib/dvswitch/dvs/var.txt
	declare call_sign_M=$call_sign
	if [ ${#call_sign} = 4 ]; then declare call_sign_M="$call_sign$sp02"; fi
	if [ ${#call_sign} = 5 ]; then declare call_sign_M="$call_sign$sp01"; fi
	declare dmr_id_M=$dmr_id
	declare rpt_id_M=$rpt_id
	declare ext_M=${rpt_id:7:2}
	declare usrp_port_M=$usrp_port


user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ]; then
	source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
	declare call_sign${user}=$call_sign
	if [ ${#call_sign} = 4 ]; then declare call_sign${user}="$call_sign$sp02"; fi
	if [ ${#call_sign} = 5 ]; then declare call_sign${user}="$call_sign$sp01"; fi
	declare dmr_id${user}=$dmr_id
	declare rpt_id${user}=$rpt_id
	declare ext${user}=${rpt_id:7:2}
	declare usrp_port${user}=$usrp_port
fi
done


sel=$(whiptail --title " DVSwitch Multi User " --menu "\
               v.1.1 by HL5KY
\n
" 33 50 24 \
"M" "MAIN   $call_sign_M $dmr_id_M $ext_M $usrp_port_M" \
"=" "===============================" \
"1" "User01 $call_sign01 $dmr_id01 $ext01 $usrp_port01" \
"2" "User02 $call_sign02 $dmr_id02 $ext02 $usrp_port02" \
"3" "User03 $call_sign03 $dmr_id03 $ext03 $usrp_port03" \
"4" "User04 $call_sign04 $dmr_id04 $ext04 $usrp_port04" \
"5" "User05 $call_sign05 $dmr_id05 $ext05 $usrp_port05" \
"6" "User06 $call_sign06 $dmr_id06 $ext06 $usrp_port06" \
"7" "User07 $call_sign07 $dmr_id07 $ext07 $usrp_port07" \
"8" "User08 $call_sign08 $dmr_id08 $ext08 $usrp_port08" \
"9" "User09 $call_sign09 $dmr_id09 $ext09 $usrp_port09" \
"10" "User10 $call_sign10 $dmr_id10 $ext10 $usrp_port10" \
"11" "User11 $call_sign11 $dmr_id11 $ext11 $usrp_port11" \
"12" "User12 $call_sign12 $dmr_id12 $ext12 $usrp_port12" \
"13" "User13 $call_sign13 $dmr_id13 $ext13 $usrp_port13" \
"14" "User14 $call_sign14 $dmr_id14 $ext14 $usrp_port14" \
"15" "User15 $call_sign15 $dmr_id15 $ext15 $usrp_port15" \
"16" "User16 $call_sign16 $dmr_id16 $ext16 $usrp_port16" \
"17" "User17 $call_sign17 $dmr_id17 $ext17 $usrp_port17" \
"18" "User18 $call_sign18 $dmr_id18 $ext18 $usrp_port18" \
"19" "User19 $call_sign19 $dmr_id19 $ext19 $usrp_port19" \
"20" "User20 $call_sign20 $dmr_id20 $ext20 $usrp_port20" \
"=" "===============================" \
"U" "Multi User 업그레이드/자동설정" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then exit 0; fi

case $sel in
M)
main_user_config ;;
=)
${DVS}dvsmu ;;
1)
user_config 01 ;;
2)
user_config 02 ;;
3)
user_config 03 ;;
4)
user_config 04 ;;
5)
user_config 05 ;;
6)
user_config 06 ;;
7)
user_config 07 ;;
8)
user_config 08 ;;
9)
user_config 09 ;;
10)
user_config 10 ;;
11)
user_config 11 ;;
12)
user_config 12 ;;
13)
user_config 13 ;;
14)
user_config 14 ;;
15)
user_config 15 ;;
16)
user_config 16 ;;
17)
user_config 17 ;;
18)
user_config 18 ;;
19)
user_config 19 ;;
20)
user_config 20 ;;
" ")
${DVS}dvsmu ;;
U)
upgrade ;;
esac

exit 0



