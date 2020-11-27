#!/bin/bash


user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
	log_dir=/home/dvswitch/user${user}
	if [ -d $log_dir ]; then
		file=/home/dvswitch/user${user}/Analog_Bridge.log
		date=$(date -d '4 day ago' '+%Y-%m-%d')
		row_no=$(grep -n $date $file | cut -d: -f1 | head -1)
		sudo sed -i "1,${row_no}d" $file
	fi
done


log_dir=/var/log/dvswitch
sudo find ${log_dir}/*.log -mtime +4 -exec rm -f {} \;

log_dir=/var/log/mmdvm
sudo find ${log_dir}/*.log -mtime +4 -exec rm -f {} \;


