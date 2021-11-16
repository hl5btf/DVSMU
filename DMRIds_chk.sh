#!/bin/bash

source /var/lib/dvswitch/dvs/var.txt

#===================================
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="HL5KY"
SCRIPT_DATE="2021-11-16"
#===================================

FILE_DAT=/var/lib/mmdvm/DMRIds.dat
FILE_NEW=/var/lib/mmdvm/DMRIds.new
FILE_BAK=/var/lib/mmdvm/DMRIds.bak
LIB=/var/lib/mmdvm


FILE_THIS=${DVS}DMRIds_chk.sh
FILE_CRON=/etc/crontab

MIN_FILE_SIZE=4579118
MIN_NUMBER_HL=1428

MAX_LOG_LINE=300

CHK_CALLSIGNS="HL5KY HL5BTF HL5BHH HL5PPT HL2DRY DS5QDR DS5ANY DS5TUK JA2HWE ZL1SN"

min=$(sed -n -e '/DMRIds/p' $FILE_CRON | cut -f 1 -d' ')

cron_daily_time=$(sed -n -e '/cron.daily/p' $FILE_CRON | cut -f 2 -d' ')
cron_daily_min=$(sed -n -e '/cron.daily/p' $FILE_CRON | cut -f 1 -d' ')
cron_daily_min_plus_2=$((cron_daily_min + 2))
cron_daily_min_plus_3=$((cron_daily_min + 3))

#--------------------------------------------------------------
function set_chk_time_agn_1min() {
sudo sed -i -e "/DMRIds/ c $cron_daily_min_plus_3 $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh" /etc/crontab
}
#--------------------------------------------------------------
function set_chk_time_agn_10min() {

min=$(sed -n -e '/DMRIds/p' $FILE_CRON | cut -f 1 -d' ')
new_min=$((min + 10))

if [ $new_min -ge 60 ]; then
	sudo sed -i -e "/DMRIds/ c $cron_daily_min_plus_2 $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh" $FILE_CRON
else
	sudo sed -i -e "/DMRIds/ c $new_min $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh" $FILE_CRON
fi
}
#--------------------------------------------------------------
function err_log() {

time=`date -d '14 hour' +%Y-%m-%d'  '%H:%M:%S`

echo $time $err_type | sudo tee -a ${DVS}DMRIds.log > /dev/null 2>&1

line=`cat ${DVS}DMRIds.log | wc -l`

if [ $line -gt $MAX_LOG_LINE ]; then
	sudo sed -i '1d' ${DVS}DMRIds.log
fi
}
#--------------------------------------------------------------
function cp_bak_to_dat() {

if [ -e $FILE_BAK ]; then
	sudo cp -f $FILE_BAK $FILE_DAT
fi
}
#--------------------------------------------------------------
function db_download() {
${DEBUG} curl -s -N "https://database.radioid.net/static/user.csv" | awk -F, 'NR>1 {if ($1 > "") print $1,$2,$3}' | sudo tee $FILE_NEW  > /dev/null 2>&1
}
#--------------------------------------------------------------
function file_size_chk() {

FILE_SIZE=$(wc -c $FILE_CHK | awk '{print $1}')

if [ $FILE_SIZE -lt $MIN_FILE_SIZE ]; then #smaller
	chk_result=no
else    #greater
	chk_result=ok
fi
}
#--------------------------------------------------------------
function hl_num_chk() {

NUMBER_HL=$(grep ^450  $FILE_CHK | wc -l)

if [ $NUMBER_HL -lt $MIN_NUMBER_HL ]; then #smaller
	chk_result=no
else    #greater
	chk_result=ok
fi
}
#--------------------------------------------------------------
function callsign_chk() {

for CALLSIGN in ${CHK_CALLSIGNS}; do
        if [[ -z `grep $CALLSIGN $FILE_NEW` ]]; then
		chk_result=no
		break
	else
		chk_result=ok
        fi
done
}

#==============================================================
# MAIN
#==============================================================

if [ $min = $cron_daily_min_plus_2 ]; then

	FILE_CHK=/var/lib/mmdvm/DMRIds.dat

	file_size_chk
	if [ $chk_result = no ]; then
		set_chk_time_agn_1min
		err_type=dat_file_size_err; err_log
		cp_bak_to_dat
		exit
	fi

	hl_num_chk
	if [ $chk_result = no ]; then
		set_chk_time_agn_1min
		err_type=dat_file_hl_num_err; err_log
                cp_bak_to_dat
                exit
	fi

        callsign_chk
        if [ $chk_result = no ]; then
		set_chk_time_agn_1min
		err_type=dat_file_callsign_err; err_log
                cp_bak_to_dat
                exit
        fi

	sudo cp -f $FILE_DAT $FILE_BAK

else
        FILE_CHK=/var/lib/mmdvm/DMRIds.new

	db_download

	file_size_chk
	if [ $chk_result = no ]; then
		set_chk_time_agn_10min
		err_type=new_file_size_err; err_log
		exit
	fi

	hl_num_chk
	if [ $chk_result = no ]; then
		set_chk_time_agn_10min
		err_type=new_file_hl_num_err; err_log
		exit
	fi

	callsign_chk
        if [ $chk_result = no ]; then
                set_chk_time_agn_10min
		err_type=new_file_callsign_err; err_log
		exit
        fi


# when all checks for new file are ok, excute followings

        sudo sed -i -e "/DMRIds/ c $cron_daily_min_plus_2 $cron_daily_time * * * root /usr/local/dvs/DMRIds_chk.sh" /etc/crontab

	NEW_MIN_FILE_SIZE=$(($FILE_SIZE-1000))
	sudo sed -i -e "/^MIN_FILE_SIZE/ c MIN_FILE_SIZE=$NEW_MIN_FILE_SIZE" $FILE_THIS

	NEW_MIN_NUMBER_HL=$(($NUMBER_HL-10))
	sudo sed -i -e "/^MIN_NUMBER_HL/ c MIN_NUMBER_HL=$NEW_MIN_NUMBER_HL" $FILE_THIS

	sudo cp -f $FILE_NEW $FILE_DAT
	sudo cp -f $FILE_NEW $FILE_BAK
fi

