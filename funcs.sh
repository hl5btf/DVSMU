
#--------------------------------------------------------------
# Function pse_wait
#--------------------------------------------------------------
function pse_wait() {
TERM=ansi whiptail --title "$T029" --infobox "$T006 (Please Wait...)" 8 60
}

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

file=/opt/user$USER_NO/Analog_Bridge.ini
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
# Function main_user_dvswitch_upgrade
###############################################################
function main_user_dvswitch_upgrade() {

source /var/lib/dvswitch/dvs/var.txt

sudo \mv -f ${DATA}var.txt ${DATA}var.old > /dev/null 2>&1

sudo apt-get update -y

sudo apt-get install dvswitch-server -y > /dev/null 2>&1

sudo \mv -f /var/lib/dvswitch/dvs/var.old /var/lib/dvswitch/dvs/var.txt > /dev/null 2>&1

# After upgrading, if [there is dvsm.basic] -> meaning setting is Advanced Macro Configuration
if [ -e ${AB}dvsm.basic ]; then
#    if there is not character "Advanced" in dvsm.macro -> updated & upgraded and dvsm.macro is brand new
        if [[ -z `grep "Advanced" ${AB}dvsm.macro` ]]; then
                sudo \cp -f ${adv}dvsm.macro ${AB}dvsm.macro
        fi
fi

language=`echo ${language} | tr '[A-Z]' '[a-z]'`
sudo \cp -f ${lan}${language}.txt ${lan}language.txt


if [[ -z `sudo grep ${dmr_id} ${AB}Analog_Bridge.ini` ]] || \
[[ -z `sudo grep ${call_sign} ${MB}MMDVM_Bridge.ini` ]] || \
[[ -z `sudo grep ${call_sign} /opt/NXDNGateway/NXDNGateway.ini` ]] || \
[[ -z `sudo grep ${call_sign} /opt/P25Gateway/P25Gateway.ini` ]] || \
[[ -z `sudo grep ${call_sign} /opt/YSFGateway/YSFGateway.ini` ]] || \
[[ -z `sudo grep ${call_sign} /etc/ircddbgateway` ]];
then


sudo ${DVS}config_main_user.sh return

sudo systemctl restart $services > /dev/null 2>&1

fi
}
#==============================================================
# END of main_user_dvswitch_upgrade
#==============================================================

###############################################################
# Function file_copy_and_initialize
###############################################################
function file_copy_and_initialize() {

sudo cp /opt/Analog_Bridge/* /opt/user$1
sudo cp /opt/MMDVM_Bridge/* /opt/user$1
sudo cp /opt/md380-emu/md380-emu /opt/user$1

file=/opt/user$1/MMDVM_Bridge.ini
	$update_ini $file "DMR Network" Password none

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

if [ "${macro_lan}" = "KOR" ]; then

        sudo \cp -f ${adv}user00KR/*.* /opt/user$1
else
        sudo \cp -f ${adv}user00EN/*.* /opt/user$1
fi
}

#==============================================================
# END of file_copy_and_initialize
#==============================================================

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
	dmr="ambeMode = DMR"
	sudo sed -i "/^ambeMode/ c $dmr" $file

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
file_var=/var/lib/dvswitch/dvs/var$USER_NO.txt

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
                if [[ "$dvs_TA" == *"%callsign"* || -z "$dvs_TA" ]]; then
                        tag=talkerAlias; value="dvsMultiUser by HL5KY"
                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var

                        sudo systemctl stop mmdvm_bridge > /dev/null 2>&1
                        $update_ini $file DMR talkerAlias "dvsMultiUser by HL5KY"
                        sudo systemctl start mmdvm_bridge > /dev/null 2>&1

                # dvs_TA가 공란이 아니면
                elif [[ -n "$dvs_TA" ]]; then
                        tag=talkerAlias; value="$dvs_TA"
                        sudo sed -i -e "s/^$tag=.*/$tag=\"$value\"/" $file_var
                fi
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


