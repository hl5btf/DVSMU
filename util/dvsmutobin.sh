#!/bin/bash

DVS=/usr/local/dvs/
HOME=/home/dvswitch/
SHC=/home/dvswitch/shc-3.8.9/

sudo \cp -f ${DVS}dvsmu ${DVS}dvsmu.bak
sudo \cp -f ${DVS}dvsmu ${DVS}dvsmu.sh

sudo \cp -f ${DVS}dvsmu.sh ${HOME}dvsmu.sh

${SHC}shc -r -v -T -f ${HOME}dvsmu.sh
sudo mv ${HOME}dvsmu.sh.x ${HOME}dvsmu
