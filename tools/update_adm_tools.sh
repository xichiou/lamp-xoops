#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS
#   Description:
#   Author: 邱顯錫 (Chiou, Hsienhsi)
#   Intro:  https://github.com/xichiou/lamp-xoops
#===============================================================================================

TADTOOLS_VERSION=3.26
TADTOOLS_URL="http://120.115.2.90/modules/tad_modules/index.php?op=tufdl&files_sn=1961#tadtools_3.26_20190509.zip"

TAD_ADM_VERSION=2.81
TAD_ADM_URL="http://120.115.2.90/modules/tad_modules/index.php?op=tufdl&files_sn=1962#tad_adm_2.81_20190509.zip"

clear

# Current folder
cur_dir=`pwd`

# Get public IP
function getIP(){
    #IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[1-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
    IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^10\.|^127\.|^255\." | head -n 1`
    if [[ "$IP" = "" ]]; then
        IP=`curl -s -4 icanhazip.com`
    fi
}

getIP




echo "下載模組並解開： tadtools 工具包..."
if ! [ -f tadtools_${TADTOOLS_VERSION}.zip ];then
	wget $TADTOOLS_URL -O tadtools_${TADTOOLS_VERSION}.zip
fi
rm -rf tadtools
unzip -q tadtools_${TADTOOLS_VERSION}.zip
chown -R apache.apache tadtools

echo "下載模組並解開： tad_adm 站長工具箱..."
if ! [ -f tad_adm_${TAD_ADM_VERSION}.zip ];then
	wget $TAD_ADM_URL -O tad_adm_${TAD_ADM_VERSION}.zip
fi
rm -rf tad_adm
unzip -q tad_adm_${TAD_ADM_VERSION}.zip
chown -R apache.apache tad_adm

echo "下載更新並解開： BootStrap4升級補丁"
if ! [ -f bs4_upgrade.zip ];then
	wget 'http://120.115.2.90/modules/tad_modules/xoops.php?op=tufdl&files_sn=1845#bs4_upgrade_20190101.zip' -O bs4_upgrade.zip
fi

if ! [ -d patch ]; then
	mkdir patch
fi
cd patch
unzip -q -o ../bs4_upgrade.zip
chown -R apache.apache .
