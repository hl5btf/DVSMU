#!/bin/bash

# dvsmu를 만들고 나서, Binary로 바꾸고 Backup을 만드는 등의 작업을 자동화 함.

DVS=/usr/local/dvs/
HOME=/home/dvswitch/
SHC=/home/dvswitch/shc-3.8.9/

sudo \cp -f ${DVS}dvsmu ${DVS}dvsmu.bak
sudo \cp -f ${DVS}dvsmu ${DVS}dvsmu.sh

sudo \cp -f ${DVS}dvsmu.sh ${HOME}dvsmu.sh

${SHC}shc -r -v -T -f ${HOME}dvsmu.sh
sudo mv ${HOME}dvsmu.sh.x ${HOME}dvsmu
sudo \cp -f ${HOME}dvsmu ${DVS}dvsmu


# 아래와 같이 다운로드가 가능함 =====================================
# sudo wget -O /usr/local/dvs/dvsmutobin.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/util/dvsmutobin.sh
# sudo chmod +x /usr/local/dvs/dvsmutobin.sh


# shc 설치 ========================================================
# wget http://www.datsi.fi.upm.es/~frosal/sources/shc-3.8.9.tgz
# tar xvfz shc-3.8.9.tgz
#cd shc-3.8.9
# make (필히 실행해야 함)

# 바이너리화:
# ./shc -r -v -T -f ./파일명

# 본래의 스크립트 파일하나,
# 바이너리파일인 .x
# 그리고 쉘스크립트가 c코드로 변환되었던 .c코드가 만들어진다.
