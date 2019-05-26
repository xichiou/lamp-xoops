#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS
#   Description:
#   Author: 邱顯錫 (Chiou, Hsienhsi)
#   Intro:  https://github.com/xichiou/lamp-xoops
#===============================================================================================

cd /root
whereis wget|grep bin;
if [ $? != 0]; then
  yum install -y unzip wget
fi
rm lamp-xoops.zip
wget --no-check-certificate https://github.com/xichiou/lamp-xoops/archive/master.zip -O lamp-xoops.zip
if [ -f lamp-xoops.zip ]; then
  unzip -q -o lamp-xoops.zip
  cd lamp-xoops-master/
  chmod +x *.sh
  echo -e "\n已經取得最新 lamp_xoops 程式腳本!!\n"
else
  echo -e "更新失敗"
fi



