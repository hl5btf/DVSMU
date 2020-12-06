#!/bin/bash


user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do
        log_dir=/var/log/dvswitch/user${user}
        if [ -d $log_dir ]; then
                file=/var/log/dvswitch/user${user}/Analog_Bridge.log
                date=$(date -d '4 day ago' '+%Y-%m-%d')
                row_no=$(grep -n $date $file | cut -d: -f1 | head -1)
                if [ "$row_no" = "" ]; then row_no=1; fi
                sudo sed -i -e "1,${row_no}d" $file
        fi
done


log_dir=/var/log/dvswitch
sudo find $log_dir -name '*.log' -mtime +4 -delete


log_dir=/var/log/mmdvm
sudo find $log_dir -name '*.log' -mtime +4 -delete



