#!/bin/bash


source /var/lib/dvswitch/dvs/var.txt

TERM=ansi whiptail --title "$T029" --infobox "$T006" 8 60

#---------핫스팟 호출부호 추출 -------------------------------------------
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

#---------- 핫스팟의 BM 연결상태 확인 ------------------------------------

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
                echo "${user} yes"
                declare con_BM_M=NO; break
        else declare con_BM_M=ok
        fi
        done < test.txt
else
con_BM_M=??
fi

#echo $con_BM_M

#------------ 클라이언트의 BM 연결상태 확인 --------------------------------
user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do

file=/var/lib/dvswitch/dvs/var${user}.txt
dir=/opt/user${user}

if [ -e $file ] && [ -d $dir ]; then

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
#       	        echo "${user} yes"
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

#----------- 핫스팟의 연결시간 및 연결상태 확인 --------------------------
file1=/var/log/dvswitch/Analog_Bridge.log

n=5
log_date=$(date -d "$n day ago" '+%Y-%m-%d')
file2=/var/log/dvswitch/Analog_Bridge-$log_date.log

#until [ -e $file2 ] && [ -s $file2 ]; do
until [ -s $file2 ] || [ $n = 0 ]; do
n=$(($n-1))
if [ ! -e $file2 ] || [ ! -s $file2 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file2=/var/log/dvswitch/Analog_Bridge-$log_date.log
fi
done


if [ -s $file2 ]; then
        sudo cat $file2 | sudo tee test.txt > /dev/null 2>&1
fi


until [ $n = 0 ]; do
n=$(($n-1))
if [ ! -e $file2 ] || [ ! -s $file2 ]; then
        log_date=$(date -d "$n day ago" '+%Y-%m-%d')
        file2=/var/log/dvswitch/Analog_Bridge-$log_date.log
	sudo cat $file2 | sudo tee -a test.txt > /dev/null 2>&1
fi
done


if [ -s $file1 ]; then
        sudo cat $file1 | sudo tee -a test.txt > /dev/null 2>&1
fi

file=test.txt

if [ -e $file ] && [[ ! -z `sudo grep "change" $file -a` ]]; then

line_no_ipchange=$(sudo grep -n "change" $file -a | cut -d: -f1 | tail -1)
line_no_connect=$(sudo grep -n "USRP_TYPE_TEXT" $file -a | cut -d: -f1 | tail -1)
	if [ "$line_no_connect" = "" ]; then line_no_connect=0; fi
line_no_reset=$(sudo grep -n "USRP reset" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_reset" = "" ]; then line_no_reset=0; fi
line_no_analog_start=$(sudo grep -n "starting" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_analog_start" = "" ]; then line_no_analog_start=0; fi

if [ $line_no_ipchange -gt $line_no_reset ]; then
        line=$(sudo cat $file | sudo sed -n ${line_no_ipchange}p)
        else line=$(sudo cat $file | sudo sed -n ${line_no_reset}p)
fi

dd=${line:3:21}
declare con_cl_time_M=$(date -d "${dd} 9 hour" +"%m-%d_%H:%M")

#echo $con_cl_time_M

if [ $line_no_ipchange -gt $line_no_connect ]; then
	callsign_cl=pyUC
	else
	line=$(sudo cat $file | sudo sed -n ${line_no_connect}p)
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

#-------------- 클라이언트의 연결시간 및 연결상태 확인 --------------------
user="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20"

for user in $user; do

file=/var/lib/dvswitch/dvs/var${user}.txt
dir=/opt/user${user}

if [ -e $file ] && [ -d $dir ]; then

        file=/var/log/dvswitch/user${user}/Analog_Bridge.log

        if [[ ! -z `sudo grep "change" $file -a` ]]; then

	line_no_ipchange=$(sudo grep -n "change" $file -a | cut -d: -f1 | tail -1)
        line_no_connect=$(sudo grep -n "USRP_TYPE_TEXT" $file -a | cut -d: -f1 | tail -1)
	if [ "$line_no_connect" = "" ]; then line_no_connect=0; fi
        line_no_reset=$(sudo grep -n "USRP reset" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_reset" = "" ]; then line_no_reset=0; fi
        line_no_analog_start=$(sudo grep -n "starting" $file -a | cut -d: -f1 | tail -1)
        if [ "$line_no_analog_start" = "" ]; then line_no_analog_start=0; fi

        if [ $line_no_ipchange -gt $line_no_reset ]; then
                line=$(sudo cat $file | sudo sed -n ${line_no_ipchange}p)
                else line=$(sudo cat $file | sudo sed -n ${line_no_reset}p)
        fi

        dd=${line:3:21}
        declare con_cl_time_${user}=$(date -d "${dd} 9 hour" "+%m-%d_%H:%M")

	if [ $line_no_ipchange -gt $line_no_connect ]; then
		callsign_cl=pyUC
		else

	        line=$(sudo cat $file | sudo sed -n ${line_no_connect}p)
        	declare callsign_cl_A=$(echo $line | cut -d '(' -f 2 | cut -d ')' -f 1)
	        callsign_cl_A=`echo ${callsign_cl_A} | tr '[a-z]' '[A-Z]'`
        	declare dmrid_cl=${line: -7:7}
	        dvswitch=/opt/MMDVM_Bridge/dvswitch.sh
        	callsign=$($dvswitch lookup $dmrid_cl)
	        callsign_cl=$(echo $callsign | awk '{print $2}')

	        if [ "${#callsign_cl}" = 0 ]; then
        	        declare callsign_cl="$callsign_cl_A"
#               	declare callsign_cl="------"
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

exit 0
}
#==============================================================
# END of connection_status
#==============================================================


