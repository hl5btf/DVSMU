#!/bin/bash

# dvsmu v2.01 또는 이전 사용자를 위해서 필요함

file=/usr/local/dvs/dvsmu_upgrade.sh
sudo wget -O $file https://raw.githubusercontent.com/hl5btf/DVSMU/main/dvsmu_upgrade.sh > /dev/null 2>&1
sudo chmod +x $file
sudo $file
sudo rm $file

exit 0


# dvsmu v2.01 또는 이전 사용자를 위해서 필요함

# dvsmu v2.01까지는 function dvsmu_upgrade() 에서 아래의 파일을 다운로드해서 업그레이드하도록 되어 있기 때문에
# https://raw.githubusercontent.com/hl5btf/DVSMU/main/upgrade.sh
# 현재의 파일(upgrade.sh)을 만들어 둠
# 현재의 파일에서 dvsmu_upgrade.sh를 실행하도록 함

# 참고로 /usr/local/dvs 폴더에는 기존에 dvs용의 upgrade.sh 파일 있음
# dvsmu v2.01에서 다운로드시 기존의 파일을 덮어쓸 우려가 있기 때문에 아래와 같이 처리함
# 다운로드한 파일의 이름을 임의의 이름으로 저장하여 사용함

# random_char=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | sed 1q)
# sudo wget -O ${DVS}${random_char}.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/upgrade.sh > /dev/null 2>&1
# sudo chmod +x ${DVS}${random_char}.sh > /dev/null 2>&1;
# ${DVS}${random_char}.sh > /dev/null 2>&1;
# sudo rm ${DVS}${random_char}.sh > /dev/null 2>&1;

