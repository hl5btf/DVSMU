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


# 아래와 같이 다운로드가 가능함
# sudo wget -O /usr/local/dvs/dvsmutobin.sh https://raw.githubusercontent.com/hl5btf/DVSMU/main/util/dvsmutobin.sh
# sudo chmod +x /usr/local/dvs/dvsmutobin.sh
