#!/bin/bash

#source /var/lib/dvswitch/dvs/var.txt

#===================================
SCRIPT_VERSION="1.8"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2020-12-22"
#===================================

if [ "$1" != "" ]; then
    case $1 in
        -v|-V|--version) echo $SCRIPT_VERSION; exit 0 ;;
        -a|-A|--author) echo $SCRIPT_AUTHOR; exit 0 ;;
        -d|-D|--date) echo $SCRIPT_DATE; exit 0 ;;
    esac
fi


#--------------------------------------------------------------
# Function pse_wait
#--------------------------------------------------------------
function pse_wait() {
TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60
}

#--------------------------------------------------------------
# Function update_DV3000
#--------------------------------------------------------------
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
row_no=$(sudo grep -n "$line_contents" $file -a | cut -d: -f1)

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
# Function var_to_ini
###############################################################
function var_to_ini() {
source /var/lib/dvswitch/dvs/var$1.txt
USER_NO=$1

if [ "$2" = "upgrade" ]; then
let "complete=complete+15"
else
let "complete=complete+10"
fi
echo -e "$complete"

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

if [ "$2" = "upgrade" ]; then
let "complete=complete+15"
else
let "complete=complete+10"
fi
echo -e "$complete"

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

let "complete=complete+10"
echo -e "$complete"

	$update_ini $file DMR Enable 1
	$update_ini $file "DMR Network" Enable 1
	sudo sed -i "s/Local=62032/# Local=62032/g" $file
	$update_ini $file Info RXFrequency ${rx_freq}
	$update_ini $file Info TXFrequency ${tx_freq}
	$update_ini $file Info Power ${pwr}
	$update_ini $file Info Latitude ${lat}
	$update_ini $file Info Longitude ${lon}

if [ "$2" = "upgrade" ]; then
let "complete=complete+15"
else
let "complete=complete+10"
fi
echo -e "$complete"

	$update_ini $file Info Height ${hgt}
	$update_ini $file Info Location "${lctn}"
	$update_ini $file Info Description "${desc}"
	sudo sed -i -e "/^URL/ c URL=https:\/\/www.qrz.com\/db\/${call_sign}" $file

        $update_ini $file "DMR Network" Address ${bm_address}
        $update_ini $file "DMR Network" Password ${bm_password}
        $update_ini $file "DMR Network" Port ${bm_port}

file=/opt/user$USER_NO/DVSwitch.ini
        if [ "${talkerAlias}" = "" ];
        then    sudo sed -i -e "/talkerAlias/ c talkerAlias = " $file
        else    $update_ini $file DMR talkerAlias "${talkerAlias}"
        fi
        declare txport=$(($USER_NO_NO+31000))
        declare rxport=$(($USER_NO_NO+31300))
        $update_ini $file DMR txPort $txport
        $update_ini $file DMR rxPort $rxport

if [ "$2" = "upgrade" ]; then
let "complete=complete+15"
else
let "complete=complete+10"
fi
echo -e "$complete"

sudo systemctl enable mmdvm_bridge$USER_NO analog_bridge$USER_NO md380-emu$USER_NO > /dev/null 2>&1

if [ "$2" = "upgrade" ]; then
let "complete=complete+15"
else
let "complete=complete+10"
fi
echo -e "$complete"

sudo systemctl start mmdvm_bridge$USER_NO analog_bridge$USER_NO md380-emu$USER_NO > /dev/null 2>&1

if [ "$2" = "upgrade" ]; then
let "complete=complete+15"
else
let "complete=complete+10"
fi
echo -e "$complete"
}
#==============================================================
# END of var_to_ini
#==============================================================


###############################################################
# Function file_copy_and_initialize
###############################################################
function file_copy_and_initialize() {

sudo cp /opt/Analog_Bridge/* /opt/user$1
sudo cp /opt/MMDVM_Bridge/* /opt/user$1
sudo cp /opt/md380-emu/* /opt/user$1

sudo \cp -f ${adv}user00/dvsm.* /opt/user$1

file=/opt/user$1/dvsm.macro
        sudo sed -i "s/USER_NO/$1/g" $file

file=/opt/user$1/dvsm.adv
        sudo sed -i "s/USER_NO/$1/g" $file

file=/opt/user$1/dvsm.basic
        sudo sed -i "s/USER_NO/$1/g" $file

file=/opt/user$1/dvsm.sh
        sudo sed -i "s/USER_NO/$1/g" $file

file=/opt/user$1/DVSwitch.ini
        sudo sed -i -e "/talkerAlias/ c talkerAlias = " $file

source /var/lib/dvswitch/dvs/var$1.txt

if [ ${dmr_id:0:3} = 450  ]; then
        sudo \cp -f ${adv}user00KR/*.* /opt/user$1
else
        sudo \cp -f ${adv}user00EN/*.* /opt/user$1
fi
}
#==============================================================
# END of file_copy_and_initialize
#==============================================================


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

# USRP Port 중복 확인 루틴 이후에 다시 source를 변경하므로, 입력 변수를 call_sign_in 등과 같이 변경해서 사용함

call_sign_in=$(whiptail --title "$T009" --inputbox "$T160" 10 60 ${call_sign} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#

call_sign_in=`echo ${call_sign_in} | tr '[a-z]' '[A-Z]'`

if [ x${dmr_id} != x ]; then
dmr_id_old=${dmr_id}
else dmr_id_old=none
fi

dmr_id_in=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID ?" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#

until [ ${#dmr_id_in} = 7 ]; do
dmr_id_in=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID ?  ($T165)" 10 60 ${dmr_id} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
done

if [ "${dmr_id_old}" = ${dmr_id_in} ]; then
rpt_id_in=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 (00 ~99) ?" 10 60 ${rpt_id} 3>&1 1>&2 2>&3)
else
rpt_id_in=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 (00 ~99) ?" 10 60 ${dmr_id_in} 3>&1 1>&2 2>&3)
fi
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

until [ ${#rpt_id_in} = 9 ]; do
if [ ${dmr_id_old} = ${dmr_id} ]; then
rpt_id_in=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 ($T167)" 10 70 ${rpt_id} 3>&1 1>&2 2>&3)
else
rpt_id_in=$(whiptail --title "$T009" --inputbox "CCS7/DMR ID + $T166 ($T167)" 10 70 ${dmr_id} 3>&1 1>&2 2>&3)
fi
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
done

#--------------USRP PORT 입력 중복 확인 시작 부분 -------------------------------
usrp_port_in=$(whiptail --title "$T009" --inputbox "USRP Port? ( 50000 ~ 55000 )" 10 60 ${usrp_port} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#
source /var/lib/dvswitch/dvs/var.txt
        declare usrp_port_chk=$usrp_port
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check_M=no
        else
        declare port_check_M=ok
        fi

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"
for user in $user; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ $user != $USER_NO ]; then
        source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
        declare usrp_port_chk=$usrp_port
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check=no; break
        fi
fi
declare port_check=ok
done

until [ "$port_check_M" = ok ] && [ "$port_check" = ok ]; do
usrp_port_in=$(whiptail --title "$T009" --inputbox "Port $usrp_port_in 다른 사용자와 중복됨. 다시 입력하세요." 10 60 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

source /var/lib/dvswitch/dvs/var.txt
        declare usrp_port_chk=$usrp_port
        if [ "$usrp_port_in" = "$usrp_port_chk" ]; then
        declare port_check_M=no
        else
        declare port_check_M=ok
        fi

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ $user != $USER_NO ]; then
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

source /var/lib/dvswitch/dvs/var$1.txt
USER_NO=$1

# 입력변수를 다시 바꿈
call_sign=$call_sign_in; rpt_id=$rpt_id_in; dmr_id=$dmr_id_in; usrp_port=$usrp_port_in


#rx_MHz=${rx_freq:0:3}"."${rx_freq:3:4}

#if [[ $T213 =~ RXFrequency ]]; then T213=$T213; else T213="RXFrequency : $T213"; fi
#rx_MHz=$(whiptail --title " $T009 " --inputbox "$T213" 10 60 ${rx_MHz} 3>&1 1>&2 2>&3)
#if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

#if [[ $T216 =~ RXFrequency ]]; then T216=$T216; else T216="RXFrequency : $T216"; fi
#until [ ${#rx_MHz} = 8 ]; do
#rx_MHz=$(whiptail --title " $T009 " --inputbox "$T216" 10 60 ${rx_MHz} 3>&1 1>&2 2>&3)
#if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#done

#rx_freq=${rx_MHz:0:3}${rx_MHz:4:4}"00"


#tx_MHz=${tx_freq:0:3}"."${tx_freq:3:4}

#if [[ $T214 =~ TXFrequency ]]; then T214=$T214; else T214="TXFrequency : $T214"; fi
#tx_MHz=$(whiptail --title " $T009 " --inputbox "$T214" 10 60 ${tx_MHz} 3>&1 1>&2 2>&3)
#if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

#if [[ $T217 =~ TXFrequency ]]; then T217=$T217; else T217="TXFrequency : $T217"; fi
#until [ ${#tx_MHz} = 8 ]; do
#tx_MHz=$(whiptail --title " $T009 " --inputbox "$T217" 10 60 ${tx_MHz} 3>&1 1>&2 2>&3)
#if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi
#done

#tx_freq=${tx_MHz:0:3}${tx_MHz:4:4}"00"


if [ x${bm_password} = x ]; then bm_password=passw0rd; fi

bm_password=$(whiptail --title "$T009" --inputbox "브랜드마이스터 비밀번호" 10 60 ${bm_password} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

if [[ $T218 =~ Latitude ]]; then T218=$T218; else T218="Latitude : $T218"; fi
lat=$(whiptail --title " $T009 " --inputbox "$T218" 10 60 -- ${lat} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

if [[ $T219 =~ Longitude ]]; then T219=$T219; else T219="Longitude : $T219"; fi
lon=$(whiptail --title " $T009 " --inputbox "$T219" 10 60 -- ${lon} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

if [[ $T222 =~ Location ]]; then T222=$T222; else T222="Location : $T222"; fi
lctn=$(whiptail --title " $T009 " --inputbox "$T222" 10 60 "${lctn}" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

#if [[ $T223 =~ Description ]]; then T223=$T223; else T223="Description : $T223"; fi
#desc=$(whiptail --title " $T009 " --inputbox "$T223" 10 60 "${desc}" 3>&1 1>&2 2>&3)
#if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

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

{
let "complete=complete+10"
echo -e "$complete"


#------varxx.txt 수정 시작부분 ---------------------------------

sudo sed -i "s/USER_NO/${USER_NO}/g" /var/lib/dvswitch/dvs/var$USER_NO.txt > /dev/null 2>&1

sudo systemctl stop mmdvm_bridge$USER_NO analog_bridge$USER_NO md380-emu$USER_NO > /dev/null 2>&1
#sudo systemctl stop analog_bridge$USER_NO > /dev/null 2>&1
#sudo systemctl stop md380-emu$USER_NO > /dev/null 2>&1

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

let "complete=complete+10"
echo -e "$complete"

# update_var bm_master South_Korea_4501
update_var bm_address bm.dv.or.kr
#update_var bm_password passw0rd
update_var bm_password ${bm_password}
update_var bm_port 62031

if [ ${dmr_id:0:3} = 450  ]; then
	update_var dmrplus_address ipsc.dvham.com
	update_var dmrplus_password PASSWORD
	update_var dmrplus_port 55555
fi

#update_var rx_freq ${rx_freq}
#update_var tx_freq ${tx_freq}
#update_var pwr 0
update_var lat ${lat}
update_var lon ${lon}
#update_var hgt 0
update_var lctn "${lctn}"


# 한번 입력한 내용은 var00.txt에 반영하여 default로 사용
file=/var/lib/dvswitch/dvs/var00.txt
	sudo sed -i "/^bm_password=/ c bm_password=${bm_password}" $file
	sudo sed -i "/^lctn=/ c lctn=\"${lctn}\"" $file
	sudo sed -i "/^lat=/ c lat=${lat}" $file
	sudo sed -i "/^lon=/ c lon=${lon}" $file

#update_var desc "${desc}"

#------varxx.txt 수정 끝부분 ---------------------------------


sudo mkdir /opt/user$1 > /dev/null 2>&1

let "complete=complete+10"
echo -e "$complete"

# Function
file_copy_and_initialize $1

sudo cp ${DATA}analog_bridge00.service /lib/systemd/system/analog_bridge$1.service
sudo cp ${DATA}mmdvm_bridge00.service /lib/systemd/system/mmdvm_bridge$1.service
sudo cp ${DATA}md380-emu00.service /lib/systemd/system/md380-emu$1.service

sudo mkdir /var/log/dvswitch/user$USER_NO > /dev/null 2>&1

file=/lib/systemd/system/analog_bridge$USER_NO.service
	sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/lib/systemd/system/mmdvm_bridge$USER_NO.service
        sudo sed -i "s/USER_NO/$USER_NO/g" $file

file=/lib/systemd/system/md380-emu$USER_NO.service
	sudo sed -i "s/USER_NO/$USER_NO/g" $file
	declare emu_port=$(($USER_NO_NO+2470))
	sudo sed -i "s/2470/$emu_port/g" $file > /dev/null 2>&1
	sudo sed -i "s/2471/$emu_port/g" $file > /dev/null 2>&1

sudo mkdir ${tgdb}user$USER_NO > /dev/null 2>&1
if [ ${dmr_id:0:3} = 450  ]; then
	sudo cp ${tgdb}KR/*.* ${tgdb}user$USER_NO
else
	sudo cp ${tgdb}EN/*.* ${tgdb}user$USER_NO
fi

# Function
var_to_ini $USER_NO


let "complete=complete+10"
echo -e "$complete"

sleep 1

} |whiptail --title "$T029" --gauge "$T006..." 6 60 0

clear
whiptail --msgbox "\

$sp10 설정이 완료되었습니다.
" 9 50 1

${DVS}dvsmu; exit 0
}
#==============================================================
# END of user_input
#==============================================================


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

pse_wait

sudo systemctl stop mmdvm_bridge$USER_NO analog_bridge$USER_NO md380-emu$USER_NO > /dev/null 2>&1

sudo systemctl disable mmdvm_bridge$USER_NO analog_bridge$USER_NO md380-emu$USER_NO > /dev/null 2>&1

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


clear
whiptail --msgbox "\

$sp10 작업이 완료되었습니다.
" 9 50 1

${DVS}dvsmu; exit 0
}
#==============================================================
# END of user_delete
#==============================================================


###############################################################
# Function dvswitch_upgrade
###############################################################
function dvswitch_upgrade() {
clear
source /var/lib/dvswitch/dvs/lan/korean.txt

if (whiptail --title " DVSwitch 업그레이드 " --yesno "\
$sp02(dvs에서 주사용자의 DVSwitch를 업그레이드 한 후, 본 작업을 진행하는것이 좋습니다)

$sp03 주사용자와 추가사용자의 DVSwitch 프로그램을 비교한 후 업그레이드합니다.

$sp03 비교작업을 진행하시겠습니까?  $T005
" 12 90);
        then :
        else ${DVS}dvsmu A; exit 0
fi

#-----------------------------------------------------------

pse_wait

user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
if [ -d /opt/user${user} ]; then
        mmdvm=$(diff -s /opt/MMDVM_Bridge/MMDVM_Bridge /opt/user${user}/MMDVM_Bridge)
        mmdvm=$(echo "$mmdvm" | rev | cut -d' ' -f1 | rev)

        analog=$(diff -s /opt/Analog_Bridge/Analog_Bridge /opt/user${user}/Analog_Bridge)
        analog=$(echo "$analog" | rev | cut -d' ' -f1 | rev)

        dvs_M=$(/opt/MMDVM_Bridge/dvswitch.sh version)
        dvs_u=$(/opt/user${user}/dvswitch.sh version)

        if [ $mmdvm != "identical" ] || [ $analog != "identical" ] || [ "$dvs_M" != "$dvs_u" ]; then
                upgrade=yes; break
        fi
fi
done

#-----------------------------------------------------------
if [ "$upgrade" = yes ]; then :

else
        clear
        whiptail --msgbox "\

$sp06 주사용자와 동일한 버전을 사용중입니다.
        " 9 60 1

        ${DVS}dvsmu A; exit 0
fi

source /var/lib/dvswitch/dvs/lan/korean.txt

if (whiptail --title " DVSwitch 업그레이드 " --yesno "\
$sp03 주사용자의 DVSwitch 프로그램 중 일부가 업그레이드되었습니다.

$sp03 추가사용자 DVSwitch를 업그레이드/재설정 하시겠습니까? (사용자당 약 20초)

$sp03 $T005
" 12 85);
        then :
        else ${DVS}dvsmu A; exit 0
fi
if [ $? != 0 ]; then ${DVS}dvsmu A; exit 0; fi

#-----------------------------------------------------------
user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do

source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1

if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
{
let "complete=complete+15"
echo -e "$complete"

	sudo systemctl stop mmdvm_bridge${user} analog_bridge${user} md380-emu${user} > /dev/null 2>&1

	# Function
	file_copy_and_initialize ${user}

	var_to_ini ${user} upgrade

} |whiptail --title "$T029" --gauge "User${user} 업그레이드 및 설정중..." 6 60 0

fi
done
#-----------------------------------------------------------
clear
whiptail --msgbox "\

$sp04 업그레이드 및 설정이 완료되었습니다.
" 9 50 1

${DVS}dvsmu A; exit 0
}
#==============================================================
# END of dvswitch_upgrade
#==============================================================


###############################################################
# Function dvsmu_upgrade
###############################################################
function dvsmu_upgrade() {

clear
source /var/lib/dvswitch/dvs/lan/korean.txt
TERM=ansi whiptail --title "확인중" --infobox "$T006" 8 60

random_char=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | sed 1q)
sudo wget -O ${DVS}${random_char} https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu_ver > /dev/null 2>&1

source /usr/local/dvs/${random_char}
new_ver=$ver

source /var/lib/dvswitch/dvs/var.txt
sudo rm ${DVS}${random_char}
crnt_ver=$(dvsmu -v)
#-----------------------------------------------------------
if [ $new_ver = $crnt_ver ]; then

        clear
        whiptail --msgbox "\

$sp04 현재 v.${crnt_ver}  최신 버전을 사용중입니다.
        " 9 50 1

        ${DVS}dvsmu A; exit 0
else
#-----------------------------------------------------------
	clear
        if (whiptail --title " dvsMU 업그레이드 " --yesno "\
$sp10 최신버전(v.$new_ver)으로 업그레이드가 가능합니다.

$sp10 업그레이드 하시겠습니까?

$sp10 $T005
        " 12 70);
        then
	pse_wait
        random_char=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | sed 1q)
        sudo wget -O ${DVS}${random_char}.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/upgrade.sh > /dev/null 2>&1
        sudo chmod +x ${DVS}${random_char}.sh > /dev/null 2>&1;
        ${DVS}${random_char}.sh > /dev/null 2>&1;
        sudo rm ${DVS}${random_char}.sh > /dev/null 2>&1;
#-----------------------------------------------------------
	clear
	whiptail --msgbox "\

$sp08 업그레이드가 완료되었습니다.
	" 9 50 1

	${DVS}dvsmu A; exit 0

        else ${DVS}dvsmu A; exit 0
	fi
fi
}
#==============================================================
# END of dvsmu_upgrade
#==============================================================


#--------------------------------------------------------------
# Function log_error_msg
#--------------------------------------------------------------
function log_error_msg() {
if [ $log_error_cnt = 1 ]; then :
else
log_error_cnt=$(($log_error_cnt+1))
clear
whiptail --msgbox "\
$sp05 실시간 로그가 보이지 않으면,

$sp05 PTT를 한번 잡은 후, 다시 실행해 보시기 바랍니다.
" 10 60 1
fi
}

#--------------------------------------------------------------
# Function main_user_log
#--------------------------------------------------------------
function main_user_log() {
log_error_cnt=0
clear
whiptail --msgbox "\
$sp08 로그시간 = UTC

$sp08 로그 종료 명령은 q 또는 Ctrl-C
" 10 50 1

#---file1->MMDVM_Bridge.log-----------

file1=/var/log/mmdvm/MMDVM_Bridge.log

n=0
until [ -e $file1 ] && [ -s $file1 ]; do
if [ ! -e $file1 ] || [ ! -s $file1 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file1=/var/log/mmdvm/MMDVM_Bridge-$log_date.log
fi
n=$(($n+1))
done

date_utc=$(date -d '9 hour ago' '+%Y-%m-%d')

if [ $date_utc = $log_date ]; then :
else log_error_msg
fi

#---file2->Analog_Bridge.log--------------

file2=/var/log/dvswitch/Analog_Bridge.log

n=0
until [ -e $file2 ] && [ -s $file2 ]; do
if [ ! -e $file2 ] || [ ! -s $file2 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file2=/var/log/dvswitch/Analog_Bridge-$log_date.log
fi
n=$(($n+1))
done

date_utc=$(date -d '9 hour ago' '+%Y-%m-%d')

if [ $date_utc = $log_date ]; then :
else log_error_msg
fi

multitail $file1 $file2
${DVS}dvsmu M
}

###############################################################
# Function main_user_config
###############################################################
function main_user_config() {

source /var/lib/dvswitch/dvs/var.txt

declare ext=${rpt_id:7:2}


if [[ $T031 =~ $call_sign ]] && [ ${#call_sign} = 5 ];then

sel3=$(whiptail --title " Main User Configuration " --menu "\
\n
$sp05 MAIN_USER  $call_sign $dmr_id $ext $usrp_port
-------------------------------------------------------
" 21 50 10 \
"1" "실시간 로그 확인" \
"2" "var.txt" \
"3" "Analog_Bridge.ini" \
"4" "MMDVM_Bridge.ini" \
"5" "DVSwitch.ini" \
"6" "dvswitch.sh" \
"7" "dvsm.macro" \
"8" "dvsm.sh" \
"9" "서비스 재시작" \
"10" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel3 in
1)
main_user_log ;;
2)
sudo nano /var/lib/dvswitch/dvs/var.txt; ${DVS}dvsmu M ;;
3)
sudo nano /opt/Analog_Bridge/Analog_Bridge.ini; ${DVS}dvsmu M ;;
4)
sudo nano /opt/MMDVM_Bridge/MMDVM_Bridge.ini; ${DVS}dvsmu M ;;
5)
sudo nano /opt/MMDVM_Bridge/DVSwitch.ini; ${DVS}dvsmu M ;;
6)
sudo nano /opt/MMDVM_Bridge/dvswitch.sh; ${DVS}dvsmu M ;;
7)
sudo nano /opt/Analog_Bridge/dvsm.macro; ${DVS}dvsmu M ;;
8)
sudo nano /opt/Analog_Bridge/dvsm.sh; ${DVS}dvsmu M ;;
9)
pse_wait
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
10)
${DVS}dvsmu; exit 0 ;;
esac

else

sel3=$(whiptail --title " Main User Configuration " --menu "\
\n
$sp05 MAIN_USER  $call_sign $dmr_id $ext $usrp_port
-------------------------------------------------------
" 14 50 3 \
"1" "실시간 로그 확인" \
"2" "서비스 재시작" \
"3" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel3 in
1)
main_user_log ;;
2)
pse_wait
${DVS}88_restart.sh; ${DVS}dvsmu M ;;
3)
${DVS}dvsmu; exit 0 ;;
esac

fi
exit 0
}
#==============================================================
# END of main_user_config
#==============================================================


#--------------------------------------------------------------
# Function restart
#--------------------------------------------------------------
function restart() {

source /var/lib/dvswitch/dvs/var$1.txt > /dev/null 2>&1

USER_NO=$1

pse_wait

sudo systemctl restart mmdvm_bridge$USER_NO analog_bridge$USER_NO md380-emu$USER_NO > /dev/null 2>&1

${DVS}dvsmu $USER_NO; exit 0
}

#--------------------------------------------------------------
# Function sub_user_log
#--------------------------------------------------------------
function sub_user_log() {
log_error_cnt=0
clear
whiptail --msgbox "\
$sp08 로그시간 = UTC

$sp08 로그 종료 명령은 q 또는 Ctrl-C
" 10 50 1

#---file1->MMDVM_Bridge.log-----------

file1=/var/log/mmdvm/MMDVM_Bridge$USER_NO.log;

n=0
until [ -e $file1 ] && [ -s $file1 ]; do
if [ ! -e $file1 ] || [ ! -s $file1 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file1=/var/log/mmdvm/MMDVM_Bridge$USER_NO-$log_date.log
fi
n=$(($n+1))
done

date_utc=$(date -d '9 hour ago' '+%Y-%m-%d')

if [ $date_utc = $log_date ]; then :
else log_error_msg
fi

#---file2->Analog_Bridge.log--------------

file2=/var/log/dvswitch/user$USER_NO/Analog_Bridge.log;

n=0
until [ -e $file2 ] && [ -s $file2 ]; do
n=$(($n+1))
if [ ! -e $file2 ] || [ ! -s $file2 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file2=/var/log/dvswitch/user$USER_NO/Analog_Bridge-$log_date.log
fi
done

date_utc=$(date -d '9 hour ago' '+%Y-%m-%d')

if [ $date_utc = $log_date ]; then :
else log_error_msg
fi

multitail $file1 $file2;
${DVS}dvsmu $USER_NO
}

#--------------------------------------------------------------
# Function TA_input
#--------------------------------------------------------------
function TA_input() {

USER_NO=$1

source /var/lib/dvswitch/dvs/var$USER_NO.txt > /dev/null 2>&1
TA_in=$(whiptail --title "talkerAlias" --inputbox "\

기본값(공백) :
    안드로이드 사용자의 호출부호/이름 전달(BM의 기능)
    (예: VK3AZN Bob)

정보 수정 :
    수정한 내용으로 전달
    (예: VK3AZN dvsMU)

" 16 60 "${talkerAlias}" 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then ${DVS}dvsmu $USER_NO; exit 0; fi

TA_in_no_blank=$(echo ${TA_in} | tr -d ' ')
TA_no=${#TA_in_no_blank}

if [ ${TA_no} = 0 ]; then TA_in=""; fi

source /var/lib/dvswitch/dvs/var$USER_NO.txt > /dev/null 2>&1
if [ "${TA_in}" != "${talkerAlias}" ]; then
        pse_wait
        update_var talkerAlias "${TA_in}"
file=/opt/user$USER_NO/DVSwitch.ini
        if [ "${TA_in}" = "" ];
        then    sudo sed -i -e "/talkerAlias/ c talkerAlias = " $file
        else    $update_ini $file DMR talkerAlias "${TA_in}"
        fi
	restart $USER_NO
fi
${DVS}dvsmu $USER_NO
}

###############################################################
# Function sub_user_config
###############################################################
function sub_user_config() {

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
declare TA="${talkerAlias:0:15}"
if [ "$TA" = "" ]; then TA=공백; fi

file=/opt/user$USER_NO/dvsm.macro

if [ -e $file ]; then
	if [[ ! -z `sudo grep "Advanced" $file -a` ]]; then
	macro_status="수정매크로사용중"
	else macro_status="기본매크로사용중"
	fi
fi

#-------------------------------------------------------------
if [[ $T031 =~ $call_sign_M ]] && [ ${#call_sign_M} = 5 ];then

sel2=$(whiptail --title " User Configuration " --menu "\
\n
$sp02 User$USER_NO  $call_sign $dmr_id $ext $usrp_port $macro_status
-------------------------------------------------------
" 25 55 14 \
"1" "실시간 로그 확인" \
"2" "사용자 설정 변경" \
"3" "var${USER_NO}.txt" \
"4" "Analog_Bridge.ini" \
"5" "MMDVM_Bridge.ini" \
"6" "DVSwitch.ini" \
"7" "dvsm.macro" \
"8" "dvsm.sh" \
"9" "기본매크로로 변경" \
"10" "수정매크로로 변경" \
"11" "talkerAlias ($TA)" \
"12" "서비스 재시작" \
"13" "사용자 삭제" \
"14" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel2 in
1)
sub_user_log ;;
2)
user_input $1 ;;
3)
sudo nano /var/lib/dvswitch/dvs/var$USER_NO.txt; ${DVS}dvsmu $USER_NO ;;
4)
sudo nano /opt/user$1/Analog_Bridge.ini; ${DVS}dvsmu $USER_NO ;;
5)
sudo nano /opt/user$1/MMDVM_Bridge.ini; ${DVS}dvsmu $USER_NO ;;
6)
sudo nano /opt/user$1/DVSwitch.ini; ${DVS}dvsmu $USER_NO ;;
7)
sudo nano /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
8)
sudo nano /opt/user$1/dvsm.sh; ${DVS}dvsmu $USER_NO ;;
9)
sudo \cp -f /opt/user$1/dvsm.basic /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
10)
sudo \cp -f /opt/user$1/dvsm.adv /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
11)
TA_input $USER_NO ;;
12)
restart $USER_NO ;;
13)
user_delete $USER_NO ;;
14)
${DVS}dvsmu; exit 0 ;;
esac

else

sel2=$(whiptail --title " User Configuration " --menu "\
\n
$sp02 User$USER_NO  $call_sign $dmr_id $ext $usrp_port $macro_status
-------------------------------------------------------
" 19 55 8 \
"1" "실시간 로그 확인" \
"2" "사용자 설정 변경" \
"3" "서비스 재시작" \
"4" "기본매크로로 변경" \
"5" "수정매크로로 변경" \
"6" "talkerAlias ($TA)" \
"7" "사용자 삭제" \
"8" "Back to MAIN" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0; fi

case $sel2 in
1)
sub_user_log ;;
2)
user_input $1 ;;
3)
restart $USER_NO ;;
4)
sudo \cp -f /opt/user$1/dvsm.basic /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
5)
sudo \cp -f /opt/user$1/dvsm.adv /opt/user$1/dvsm.macro; ${DVS}dvsmu $USER_NO ;;
6)
TA_input $USER_NO ;;
7)
user_delete $USER_NO ;;
8)
${DVS}dvsmu; exit 0 ;;
esac
fi

exit 0
}
#==============================================================
# END of sub_user_config
#==============================================================


#--------------------------------------------------------------
# Function change_status
#--------------------------------------------------------------
function change_status() {
sel=$(whiptail --title " 설정 변경 " --menu "\
\n
" 11 30 3 \
"C" "취 소" \
"A" "활성화" \
"I" "비활성화" \
3>&1 1>&2 2>&3)

case $sel in
C)
${DVS}dvsmu O; exit 0 ;;
A)
change=A ;;
I)
change=I ;;
esac

  if [ $1 = dstar ] && [ $change = A ] && [ $dstar_chk != "active" ]; then
pse_wait
sudo systemctl enable ircddbgatewayd > /dev/null 2>&1
sudo systemctl start ircddbgatewayd > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = dstar ] && [ $change = I ] && [ $dstar_chk = "active" ]; then
pse_wait
sudo systemctl disable ircddbgatewayd quantar_bridge > /dev/null 2>&1
sudo systemctl stop ircddbgatewayd quantar_bridge > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = ysf ] && [ $change = A ] && [ $ysf_chk != "active" ]; then
pse_wait
sudo systemctl enable ysfgateway ysfparrot > /dev/null 2>&1
sudo systemctl start ysfgateway ysfparrot > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = ysf ] && [ $change = I ] && [ $ysf_chk = "active" ]; then
pse_wait
sudo systemctl disable ysfgateway ysfparrot quantar_bridge > /dev/null 2>&1
sudo systemctl stop ysfgateway ysfparrot quantar_bridge > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = nxdn ] && [ $change = A ] && [ $nxdn_chk != "active" ]; then
pse_wait
sudo systemctl enable nxdngateway nxdnparrot > /dev/null 2>&1
sudo systemctl start nxdngateway nxdnparrot > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = nxdn ] && [ $change = I ] && [ $nxdn_chk = "active" ]; then
pse_wait
sudo systemctl disable nxdngateway nxdnparrot quantar_bridge > /dev/null 2>&1
sudo systemctl stop nxdngateway nxdnparrot quantar_bridge > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = p25 ] && [ $change = A ] && [ $p25_chk != "active" ]; then
pse_wait
sudo systemctl enable p25gateway p25parrot > /dev/null 2>&1
sudo systemctl start p25gateway p25parrot > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = p25 ] && [ $change = I ] && [ $p25_chk = "active" ]; then
pse_wait
sudo systemctl disable p25gateway p25parrot quantar_bridge > /dev/null 2>&1
sudo systemctl stop p25gateway p25parrot quantar_bridge > /dev/null 2>&1
${DVS}88_restart.sh;

elif [ $1 = lighttpd ] && [ $change = A ] && [ $lighttpd_chk != "active" ]; then
pse_wait
sudo systemctl enable lighttpd webproxy > /dev/null 2>&1
sudo systemctl start lighttpd webproxy > /dev/null 2>&1

elif [ $1 = lighttpd ] && [ $change = I ] && [ $lighttpd_chk = "active" ]; then
pse_wait
sudo systemctl disable lighttpd webproxy > /dev/null 2>&1
sudo systemctl stop lighttpd webproxy > /dev/null 2>&1

elif [ $1 = monit ] && [ $change = A ] && [ $monit_chk != "active" ]; then
pse_wait
sudo systemctl enable monit > /dev/null 2>&1
sudo systemctl start monit > /dev/null 2>&1

elif [ $1 = monit ] && [ $change = I ] && [ $monit_chk = "active" ]; then
pse_wait
sudo systemctl disable monit > /dev/null 2>&1
sudo systemctl stop monit > /dev/null 2>&1

elif [ $1 = shellinabox ] && [ $change = A ] && [ $shellinabox_chk != "active" ]; then
pse_wait
sudo systemctl enable shellinabox > /dev/null 2>&1
sudo systemctl start shellinabox > /dev/null 2>&1

elif [ $1 = shellinabox ] && [ $change = I ] && [ $shellinabox_chk = "active" ]; then
pse_wait
sudo systemctl disable shellinabox > /dev/null 2>&1
sudo systemctl stop shellinabox > /dev/null 2>&1

else
clear
whiptail --msgbox "\

$sp09 상태를 변경하지 않았습니다.
" 9 50 1

fi

${DVS}dvsmu O; exit 0
}
#--------------------------------------------------------------
# END of change_status
#--------------------------------------------------------------


###############################################################
# Function system_optimizer
###############################################################
function system_optimizer() {

dstar_chk=$(systemctl is-active ircddbgatewayd)
if [ $dstar_chk = "active" ]; then dstar_sts="<< 활성상태 >>"; else dstar_sts=" 비활성상태"; fi

ysf_chk=$(systemctl is-active ysfgateway)
if [ $ysf_chk = "active" ]; then ysf_sts="<< 활성상태 >>"; else ysf_sts=" 비활성상태"; fi

nxdn_chk=$(systemctl is-active nxdngateway)
if [ $nxdn_chk = "active" ]; then nxdn_sts="<< 활성상태 >>"; else nxdn_sts=" 비활성상태"; fi

p25_chk=$(systemctl is-active p25gateway)
if [ $p25_chk = "active" ]; then p25_sts="<< 활성상태 >>"; else p25_sts=" 비활성상태"; fi

lighttpd_chk=$(systemctl is-active lighttpd)
if [ $lighttpd_chk = "active" ]; then lighttpd_sts="<< 활성상태 >>"; else lighttpd_sts=" 비활성상태"; fi

monit_chk=$(systemctl is-active monit)
if [ $monit_chk = "active" ]; then monit_sts="<< 활성상태 >>"; else monit_sts=" 비활성상태"; fi

shellinabox_chk=$(systemctl is-active shellinabox)
if [ $shellinabox_chk = "active" ]; then shellinabox_sts="<< 활성상태 >>"; else shellinabox_sts=" 비활성상태"; fi

#cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)* id.*/\1/" | awk '{printf "%.0f", 100 - $1}')
temp=$(cat /sys/class/thermal/thermal_zone0/temp)
temp=$(($temp/1000))

source /var/lib/dvswitch/dvs/var.txt

sel=$(whiptail --title " 시스템 최적화 " --menu "\
                  CPU $temp'C

            주사용자의 시스템 설정
---------------------------------------------
\n
" 19 50 8 \
"1" "DSTAR  $dstar_sts" \
"2" "YSF    $ysf_sts" \
"3" "NXDN   $nxdn_sts" \
"4" "P25    $p25_sts" \
"5" "대시보드      $lighttpd_sts" \
"6" "시스템모니터  $monit_sts" \
"7" "웹브라우저SSH $shellinabox_sts" \
"8" "Back" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu A; exit 0; fi

case $sel in
1)
change_status dstar ;;
2)
change_status ysf ;;
3)
change_status nxdn ;;
4)
change_status p25 ;;
5)
change_status lighttpd ;;
6)
change_status monit ;;
7)
change_status shellinabox ;;
8)
${DVS}dvsmu A; exit 0 ;;
esac
}
#==============================================================
# END of system_optimizer
#==============================================================


###############################################################
# Function set_reboot
###############################################################
function set_reboot() {

file=/etc/crontab

if [[ ! -z `sudo grep "reboot=" $file` ]]; then
        line_no=$(grep -n "time=" $file -a | cut -d: -f1)
        line=$(cat $file | sed -n ${line_no}p)
        timeset=$(echo $line | cut -d '=' -f 2)
        timesetplusone=$(($timeset+1))
        timeset_info_1="매일$timeset ~ $timesetplusone시"
        timeset_info_2="사용하지 않는 시간에 리부팅"
else
        timeset=""
        timeset_info_1="설정없음"
fi


source /var/lib/dvswitch/dvs/var.txt

sel=$(whiptail --title " 리부팅 시간설정 " --menu "\

$sp01 현재설정: $timeset_info_1
$sp01           $timeset_info_2
-----------------------------------------
" 14 45 3 \
"1" "리부팅 설정 및 변경" \
"2" "리부팅 설정삭제" \
"3" "Back" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then
 ${DVS}dvsmu A; exit 0; fi

case $sel in
1)
until [ "$new_timeset" != "" ]; do
new_timeset=$(whiptail --title "$T009" --inputbox "시간입력( 0 ~ 23 )" 10 60 ${timeset} 3>&1 1>&2 2>&3)
if [ $? != 0 ]; then
 ${DVS}dvsmu R; exit 0; fi
done

sudo sed -i -e "/time=/ c #time=$new_timeset" $file
sudo sed -i -e "/man_log/ c 0 $new_timeset * * * root /usr/local/dvs/man_log" $file
if [[ -z `sudo grep "reboot=yes" $file` ]]; then
        echo "#reboot=yes" | sudo tee -a $file > /dev/null 2>&1
fi
sudo systemctl restart cron
${DVS}dvsmu R; exit 0 ;;
2)
if (whiptail --title " 설정 삭제 " --yesno "\

$sp05 매일1회 리부팅 설정을 삭제하시겠습니까?

" 9 60); then
sudo sed -i -e "/time=/ c #time=5" $file
sudo sed -i -e "/man_log/ c 0 5 * * * root /usr/local/dvs/man_log" $file
sudo sed -i -e "/reboot=/d" $file
sudo systemctl restart cron
${DVS}dvsmu R; exit 0
else ${DVS}dvsmu R; exit 0
fi ;;
3)
${DVS}dvsmu A; exit 0 ;;
esac
}
#==============================================================
# END of set_reboot
#==============================================================


###############################################################
# Function connection_status
###############################################################
function connection_status() {

source /var/lib/dvswitch/dvs/lan/korean.txt
pse_wait

#---------main 및sub user의 핫스팟 호출부호 추출 -------------------------------------------
source /var/lib/dvswitch/dvs/var.txt
        declare call_sign_M=$call_sign
        if [ ${#call_sign} = 4 ]; then declare call_sign_M="$call_sign$sp02"; fi
        if [ ${#call_sign} = 5 ]; then declare call_sign_M="$call_sign$sp01"; fi


user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
        declare call_sign${user}=$call_sign
        if [ ${#call_sign} = 4 ]; then declare call_sign${user}="$call_sign$sp02"; fi
        if [ ${#call_sign} = 5 ]; then declare call_sign${user}="$call_sign$sp01"; fi
fi
done

#echo $call_sign_M
#echo $call_sign01
#echo $call_sign02

#---------- main_user의 BM 연결상태 확인 ------------------------------------

file1=/var/log/mmdvm/MMDVM_Bridge.log

n=0
#until [ -e $file1 ] && [ -s $file1 ]; do
until [ -s $file1 ] || [ $n = 5 ]; do
if [ ! -e $file1 ] || [ ! -s $file1 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file1=/var/log/mmdvm/MMDVM_Bridge-$log_date.log
fi
n=$(($n+1))
done

if [ -e $file1 ]; then
        tail -10 $file1 | sudo tee test.txt > /dev/null 2>&1
        while read line
        do
        date_10min_ago=$(date -d '9 hour ago 10 minute ago' '+%Y%m%d%H%M%S')
        dd=${line:3:22}
        ddd=$(date -d "$dd" +"%Y%m%d%H%M%S")

        if [ $ddd -gt $date_10min_ago ] && [[ $line =~ "failed" ]]; then
#                echo "${user} failed"
                declare con_BM_M=NO; break
        else declare con_BM_M=ok
        fi
        done < test.txt
else
con_BM_M=??
fi

#echo $con_BM_M

#------------ sub_user의 BM 연결상태 확인 --------------------------------
user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do

#file=/var/lib/dvswitch/dvs/var${user}.txt
dir=/opt/user${user}

#if [ -e $file ] && [ -d $dir ]; then
if [ -d $dir ]; then

        file1=/var/log/mmdvm/MMDVM_Bridge${user}.log;

        n=0
#        until [ -e $file1 ] && [ -s $file1 ]; do
        until [ -s $file1 ] || [ $n = 5 ]; do
        if [ ! -e $file1 ] || [ ! -s $file1 ]; then
                log_date=$(date -d "$n day ago" '+%Y-%m-%d')
                file1=/var/log/mmdvm/MMDVM_Bridge${user}-$log_date.log
        fi
        n=$(($n+1))
        done


        if [ -e $file1 ]; then
                tail -10 $file1 | sudo tee test.txt > /dev/null 2>&1
                while read line
                do
                date_10min_ago=$(date -d '9 hour ago 10 minute ago' '+%Y%m%d%H%M%S')
                dd=${line:3:22}
                ddd=$(date -d "$dd" +"%Y%m%d%H%M%S")

                if [ $ddd -gt $date_10min_ago ] && [[ $line =~ "failed" ]]; then
#                       echo "${user} yes"
                        declare con_BM_${user}=NO; break
                else declare con_BM_${user}=ok
                fi
                done < test.txt
        else
        con_BM_${user}=??
        fi
fi
done


#echo "con_BM_M=${con_BM_M}"
#echo "01=$con_BM_01"
#echo "02=$con_BM_02"
#echo "03=$con_BM_03"
#echo "04=$con_BM_04"
#echo "05=$con_BM_05"
#echo "06=$con_BM_06"
#echo "07=$con_BM_07"
#echo "08=$con_BM_08"
#echo "09=$con_BM_09"
#echo "10=$con_BM_10"
#echo "11=$con_BM_11"
#echo "15=$con_BM_15"
#echo "16=$con_BM_16"

#----------- main_user의 클라이언트 연결시간 및 연결상태 확인 --------------------------
file1=/var/log/dvswitch/Analog_Bridge.log

echo "" | sudo tee test.txt > /dev/null 2>&1

n=5
until [ $n = 0 ]; do
n=$(($n-1))
log_date=$(date -d "$n day ago" '+%Y-%m-%d')
file2=/var/log/dvswitch/Analog_Bridge-$log_date.log
#sudo nano $file2
if [ -e $file2 ]; then
        cat $file2 | sudo tee -a test.txt > /dev/null 2>&1
fi
done


if [ -s $file1 ]; then
        cat $file1 | sudo tee -a test.txt > /dev/null 2>&1
fi

file=test.txt

if [ -e $file ] && [[ ! -z `grep "change" $file -a` ]]; then

line_no_ipchange=$(grep -n "change" $file -a | cut -d: -f1 | tail -1)
line_no_connect=$(grep -n "USRP_TYPE_TEXT" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_connect" = "" ]; then line_no_connect=0; fi
line_no_reset=$(grep -n "USRP reset" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_reset" = "" ]; then line_no_reset=0; fi
line_no_analog_start=$(grep -n "starting" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_analog_start" = "" ]; then line_no_analog_start=0; fi

if [ $line_no_ipchange -gt $line_no_reset ]; then
        line=$(cat $file | sed -n ${line_no_ipchange}p)
        else line=$(cat $file | sed -n ${line_no_reset}p)
fi

dd=${line:3:21}
declare con_cl_time_M=$(date -d "${dd} 9 hour" +"%m-%d_%H:%M")

#echo $con_cl_time_M

if [ $line_no_ipchange -gt $line_no_connect ]; then
        callsign_cl_M=pyUC
        else
        line=$(cat $file | sed -n ${line_no_connect}p)
        callsign_cl_M_A=$(echo $line | cut -d '(' -f 2 | cut -d ')' -f 1)
        #echo $callsign_cl_M_A
        dmrid_cl_M=${line: -7:7}
        #echo $dmrid_cl_M
        dvswitch=/opt/MMDVM_Bridge/dvswitch.sh
        callsign=$($dvswitch lookup $dmrid_cl_M)
        callsign_cl_M=$(echo $callsign | awk '{print $2}')

        if [ "${#callsign_cl_M}" = 0 ]; then
                declare callsign_cl_M="$callsign_cl_M_A"
        #       declare callsign_cl_M="------"
        fi
fi

        if [ ${#callsign_cl_M} = 3 ]; then
                declare callsign_cl_M="$callsign_cl_M$sp03"
        elif [ ${#callsign_cl_M} = 4 ]; then
                declare callsign_cl_M="$callsign_cl_M$sp02"
        elif [ ${#callsign_cl_M} = 5 ]; then
                declare callsign_cl_M="$callsign_cl_M$sp01"
        fi


        if [ $line_no_connect -gt $line_no_reset ] && [ $line_no_connect -gt $line_no_analog_start ]; then
                declare con_cl_M=ok
        elif [ $line_no_ipchange -gt $line_no_reset ] && [ $line_no_ipchange -gt $line_no_analog_start ]; then
                declare con_cl_M=ok
        else
                declare con_cl_M=NO
        fi

else declare callsign_cl_M="------"

fi

#echo $callsign_cl_M
#echo $con_cl_M

#-------------- sub_user의 클라이언트 연결시간 및 연결상태 확인 --------------------
user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do

#file=/var/lib/dvswitch/dvs/var${user}.txt
dir=/opt/user${user}

#if [ -e $file ] && [ -d $dir ]; then
if [ -d $dir ]; then

        file=/var/log/dvswitch/user${user}/Analog_Bridge.log

        if [[ ! -z `grep "change" $file -a` ]]; then

        line_no_ipchange=$(grep -n "change" $file -a | cut -d: -f1 | tail -1)
        line_no_connect=$(grep -n "USRP_TYPE_TEXT" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_connect" = "" ]; then line_no_connect=0; fi
        line_no_reset=$(grep -n "USRP reset" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_reset" = "" ]; then line_no_reset=0; fi
        line_no_analog_start=$(grep -n "starting" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_analog_start" = "" ]; then line_no_analog_start=0; fi

        if [ $line_no_ipchange -gt $line_no_reset ]; then
                line=$(cat $file | sed -n ${line_no_ipchange}p)
                else line=$(cat $file | sed -n ${line_no_reset}p)
        fi

        dd=${line:3:21}
        declare con_cl_time_${user}=$(date -d "${dd} 9 hour" "+%m-%d_%H:%M")

        if [ $line_no_ipchange -gt $line_no_connect ]; then
                callsign_cl=pyUC
                else

                line=$(cat $file | sed -n ${line_no_connect}p)
                declare callsign_cl_A=$(echo $line | cut -d '(' -f 2 | cut -d ')' -f 1)
                callsign_cl_A=`echo ${callsign_cl_A} | tr '[a-z]' '[A-Z]'`
                declare dmrid_cl=${line: -7:7}
                dvswitch=/opt/MMDVM_Bridge/dvswitch.sh
                callsign=$($dvswitch lookup $dmrid_cl)
                callsign_cl=$(echo $callsign | awk '{print $2}')

                if [ "${#callsign_cl}" = 0 ]; then
                        declare callsign_cl="$callsign_cl_A"
#                       declare callsign_cl="------"
                fi
        fi

        if [ ${#callsign_cl} = 3 ]; then
                declare callsign_cl_${user}="$callsign_cl$sp03"
        elif [ ${#callsign_cl} = 4 ]; then
                declare callsign_cl_${user}="$callsign_cl$sp02"
        elif [ ${#callsign_cl} = 5 ]; then
                declare callsign_cl_${user}="$callsign_cl$sp01"
        elif [ ${#callsign_cl} = 6 ]; then
                declare callsign_cl_${user}="$callsign_cl"
        fi


        if [ $line_no_connect -gt $line_no_reset ] && [ $line_no_connect -gt $line_no_analog_start ]; then
                declare con_cl_${user}=ok
        elif [ $line_no_ipchange -gt $line_no_reset ] && [ $line_no_ipchange -gt $line_no_analog_start ]; then
                declare con_cl_${user}=ok
        else
                declare con_cl_${user}=NO
        fi

        else declare callsign_cl_${user}="------"

        fi
fi
done

#echo "01=$callsign_cl_01"
#echo "01=$con_cl_time_01"
#echo "01=$dmrid_cl_01"
#echo "02=$callsign_cl_02"
#echo "02=$con_cl_time_02"
#echo "03=$callsign_cl_03"
#echo "03=$con_cl_time_03"
#echo "04=$callsign_cl_04"
#echo "04=$con_cl_time_04"
#echo "05=$callsign_cl_05"
#echo "05=$con_cl_time_05"
#echo "06=$callsign_cl_06"
#echo "06=$con_cl_time_06"
#echo "07=$callsign_cl_07"
#echo "07=$con_cl_time_07"
#echo "08=$callsign_cl_08"
#echo "08=$con_cl_time_08"
#echo "09=$callsign_cl_09"
#echo "09=$con_cl_time_09"
#echo "15=$callsign_cl_15"
#echo "15=$con_cl_time_15"


clear
whiptail --msgbox "\

     <<< 핫스팟 및 클라이언트 연결상태 >>>


       핫스팟 BM  클라이언트_최종연결_현재상태\

   -----------------------------------------\

   M   $call_sign_M $con_BM_M   $callsign_cl_M $con_cl_time_M  $con_cl_M\

   =========================================\

   01  $call_sign01 $con_BM_01   $callsign_cl_01 $con_cl_time_01  $con_cl_01\

   02  $call_sign02 $con_BM_02   $callsign_cl_02 $con_cl_time_02  $con_cl_02\

   03  $call_sign03 $con_BM_03   $callsign_cl_03 $con_cl_time_03  $con_cl_03\

   04  $call_sign04 $con_BM_04   $callsign_cl_04 $con_cl_time_04  $con_cl_04\

   05  $call_sign05 $con_BM_05   $callsign_cl_05 $con_cl_time_05  $con_cl_05\

   06  $call_sign06 $con_BM_06   $callsign_cl_06 $con_cl_time_06  $con_cl_06\

   07  $call_sign07 $con_BM_07   $callsign_cl_07 $con_cl_time_07  $con_cl_07\

   08  $call_sign08 $con_BM_08   $callsign_cl_08 $con_cl_time_08  $con_cl_08\

   09  $call_sign09 $con_BM_09   $callsign_cl_09 $con_cl_time_09  $con_cl_09\

   10  $call_sign10 $con_BM_10   $callsign_cl_10 $con_cl_time_10  $con_cl_10\

   11  $call_sign11 $con_BM_11   $callsign_cl_11 $con_cl_time_11  $con_cl_11\

   12  $call_sign12 $con_BM_12   $callsign_cl_12 $con_cl_time_12  $con_cl_12\

   13  $call_sign13 $con_BM_13   $callsign_cl_13 $con_cl_time_13  $con_cl_13\

   14  $call_sign14 $con_BM_14   $callsign_cl_14 $con_cl_time_14  $con_cl_14\

   15  $call_sign15 $con_BM_15   $callsign_cl_15 $con_cl_time_15  $con_cl_15\

   16  $call_sign16 $con_BM_16   $callsign_cl_16 $con_cl_time_16  $con_cl_16\

   17  $call_sign17 $con_BM_17   $callsign_cl_17 $con_cl_time_17  $con_cl_17\

   18  $call_sign18 $con_BM_18   $callsign_cl_18 $con_cl_time_18  $con_cl_18\

   19  $call_sign19 $con_BM_19   $callsign_cl_19 $con_cl_time_19  $con_cl_19\

   20  $call_sign20 $con_BM_20   $callsign_cl_20 $con_cl_time_20  $con_cl_20\

   =========================================\
" 35 52 1

${DVS}dvsmu A; exit 0
}
#==============================================================
# END of connection_status
#==============================================================


###############################################################
# Function sys_admin
###############################################################
function sys_admin() {

sel=$(whiptail --title " 시스템 관리 " --menu "\
\n
" 17 50 9 \
"1" "시스템 모니터링" \
"2" "시스템 최적화" \
"3" "시스템 리부팅" \
"4" "1일1회 리부팅 설정" \
"5" "BM 및 클라이언트 연결상태 확인" \
"6" "추가사용자 DVSwitch 업그레이드" \
"7" "dvsMU (Multi User) 업그레이드" \
"8" "Back to Main" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then ${DVS}dvsmu; exit 0
fi

case $sel in
1)
clear
whiptail --msgbox "\

$sp03 시스템 모니터의 종료 명령은 F10 또는 Ctrl-C
" 9 57 1

htop; ${DVS}dvsmu A ;;
2)
system_optimizer ;;
3)
clear
source /var/lib/dvswitch/dvs/lan/korean.txt
if (whiptail --title " 시스템 리부팅 " --yesno "\

$sp10 지금 리부팅 하시겠습니까?
" 9 50);
then sudo reboot
else ${DVS}dvsmu A; exit 0
fi ;;
4)
set_reboot ;;
5)
connection_status ;;
6)
dvswitch_upgrade ;;
7)
dvsmu_upgrade ;;
8)
${DVS}dvsmu; exit 0 ;;
esac
}
#==============================================================
# END of sys_admin
#==============================================================


###############################################################
# MAIN SCRIPT
###############################################################
clear

if [ ! -e /var/lib/dvswitch/dvs/lan/language.txt ]; then
sudo \cp -f /var/lib/dvswitch/dvs/lan/korean.txt /var/lib/dvswitch/dvs/lan/language.txt
fi

USER_NO=$1

if [ "$USER_NO" = A ]; then sys_admin; fi
if [ "$USER_NO" = M ]; then main_user_config; fi
if [ "$USER_NO" = O ]; then system_optimizer; fi
if [ "$USER_NO" = R ]; then set_reboot; fi

if [ x${USER_NO} != x ] && [ ${#USER_NO} = 2 ]; then sub_user_config $USER_NO; fi

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
source /var/lib/dvswitch/dvs/var${user}.txt > /dev/null 2>&1
if [ -e /var/lib/dvswitch/dvs/var${user}.txt ] && [ x${call_sign} != x ]; then
	declare call_sign${user}=$call_sign
	if [ ${#call_sign} = 4 ]; then declare call_sign${user}="$call_sign$sp02"; fi
	if [ ${#call_sign} = 5 ]; then declare call_sign${user}="$call_sign$sp01"; fi
	declare dmr_id${user}=$dmr_id
	declare rpt_id${user}=$rpt_id
	declare ext${user}=${rpt_id:7:2}
	declare usrp_port${user}=$usrp_port
	declare talkerAlias${user}="${talkerAlias:0:13}"
#	 TA가 공백이 아니고, TA에 핫스팟관리자의 호출부호가 없으면 no_main_call_in_TA=yes
#	if [ "$talkerAlias" != "" ] && [[ "$talkerAlias" != *"$call_sign"* ]]; then show_TA=yes; fi
	if [ "$talkerAlias" != "" ]; then show_TA=yes; fi
fi
done

if [ "$show_TA" = yes ];


then

sel=$(whiptail --title " DVSwitch Multi User " --menu "\
                   dvsMU v.$SCRIPT_VERSION HL5KY
\n
" 34 60 25 \
"A" "시스템 관리" \
"M" "MAIN   $call_sign_M $dmr_id_M $ext_M $usrp_port_M talkerAlias" \
"=" "============================================" \
"01" "User01 $call_sign01 $dmr_id01 $ext01 $usrp_port01 $talkerAlias01" \
"02" "User02 $call_sign02 $dmr_id02 $ext02 $usrp_port02 $talkerAlias02" \
"03" "User03 $call_sign03 $dmr_id03 $ext03 $usrp_port03 $talkerAlias03" \
"04" "User04 $call_sign04 $dmr_id04 $ext04 $usrp_port04 $talkerAlias04" \
"05" "User05 $call_sign05 $dmr_id05 $ext05 $usrp_port05 $talkerAlias05" \
"06" "User06 $call_sign06 $dmr_id06 $ext06 $usrp_port06 $talkerAlias06" \
"07" "User07 $call_sign07 $dmr_id07 $ext07 $usrp_port07 $talkerAlias07" \
"08" "User08 $call_sign08 $dmr_id08 $ext08 $usrp_port08 $talkerAlias08" \
"09" "User09 $call_sign09 $dmr_id09 $ext09 $usrp_port09 $talkerAlias09" \
"10" "User10 $call_sign10 $dmr_id10 $ext10 $usrp_port10 $talkerAlias10" \
"11" "User11 $call_sign11 $dmr_id11 $ext11 $usrp_port11 $talkerAlias11" \
"12" "User12 $call_sign12 $dmr_id12 $ext12 $usrp_port12 $talkerAlias12" \
"13" "User13 $call_sign13 $dmr_id13 $ext13 $usrp_port13 $talkerAlias13" \
"14" "User14 $call_sign14 $dmr_id14 $ext14 $usrp_port14 $talkerAlias14" \
"15" "User15 $call_sign15 $dmr_id15 $ext15 $usrp_port15 $talkerAlias15" \
"16" "User16 $call_sign16 $dmr_id16 $ext16 $usrp_port16 $talkerAlias16" \
"17" "User17 $call_sign17 $dmr_id17 $ext17 $usrp_port17 $talkerAlias17" \
"18" "User18 $call_sign18 $dmr_id18 $ext18 $usrp_port18 $talkerAlias18" \
"19" "User19 $call_sign19 $dmr_id19 $ext19 $usrp_port19 $talkerAlias19" \
"20" "User20 $call_sign20 $dmr_id20 $ext20 $usrp_port20 $talkerAlias20" \
"=" "============================================" \
"X" "종 료" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then exit 0; fi


else

sel=$(whiptail --title " DVSwitch Multi User " --menu "\
              dvsMU v.$SCRIPT_VERSION HL5KY
\n
" 34 50 25 \
"A" "시스템 관리" \
"M" "MAIN   $call_sign_M $dmr_id_M $ext_M $usrp_port_M" \
"=" "===============================" \
"01" "User01 $call_sign01 $dmr_id01 $ext01 $usrp_port01" \
"02" "User02 $call_sign02 $dmr_id02 $ext02 $usrp_port02" \
"03" "User03 $call_sign03 $dmr_id03 $ext03 $usrp_port03" \
"04" "User04 $call_sign04 $dmr_id04 $ext04 $usrp_port04" \
"05" "User05 $call_sign05 $dmr_id05 $ext05 $usrp_port05" \
"06" "User06 $call_sign06 $dmr_id06 $ext06 $usrp_port06" \
"07" "User07 $call_sign07 $dmr_id07 $ext07 $usrp_port07" \
"08" "User08 $call_sign08 $dmr_id08 $ext08 $usrp_port08" \
"09" "User09 $call_sign09 $dmr_id09 $ext09 $usrp_port09" \
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
"X" "종 료" \
3>&1 1>&2 2>&3)

if [ $? != 0 ]; then exit 0; fi

fi


case $sel in
A)
sys_admin ;;
M)
main_user_config ;;
=)
${DVS}dvsmu ;;
01)
sub_user_config 01 ;;
02)
sub_user_config 02 ;;
03)
sub_user_config 03 ;;
04)
sub_user_config 04 ;;
05)
sub_user_config 05 ;;
06)
sub_user_config 06 ;;
07)
sub_user_config 07 ;;
08)
sub_user_config 08 ;;
09)
sub_user_config 09 ;;
10)
sub_user_config 10 ;;
11)
sub_user_config 11 ;;
12)
sub_user_config 12 ;;
13)
sub_user_config 13 ;;
14)
sub_user_config 14 ;;
15)
sub_user_config 15 ;;
16)
sub_user_config 16 ;;
17)
sub_user_config 17 ;;
18)
sub_user_config 18 ;;
19)
sub_user_config 19 ;;
20)
sub_user_config 20 ;;
" ")
${DVS}dvsmu ;;
X)
exit 0 ;;
esac

exit 0
