#!/bin/sh

SEARCH_PATH="/var/www/html"
if [ "$#" -gt 0 ]; then
  SEARCH_PATH="${SEARCH_PATH}/$1"
fi

echo -e "檢查網站目錄 $SEARCH_PATH ..."

if [ ! -f "$SEARCH_PATH/mainfile.php" ]; then
  echo "此目錄沒有 mainfile.php"
  exit 1001
fi

cd $SEARCH_PATH

XOOPS_ROOT_PATH=$(cat mainfile.php |grep "define('XOOPS_ROOT_PATH'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "XOOPS_ROOT_PATH: \e[32m$XOOPS_ROOT_PATH\e[0m"
if [ $XOOPS_ROOT_PATH != $SEARCH_PATH ]; then
  echo "XOOPS_ROOT_PATH 和實際的網站資料夾不同，可能無法運作!"
  exit 1002
fi

XOOPS_VAR_PATH=$(cat mainfile.php |grep "define('XOOPS_VAR_PATH'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "XOOPS_VAR_PATH: \e[32m$XOOPS_VAR_PATH\e[0m"
XOOPS_PATH=$(cat mainfile.php |grep "define('XOOPS_PATH'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "XOOPS_PATH: \e[32m$XOOPS_PATH\e[0m"

XOOPS_URL=$(cat mainfile.php |grep "define('XOOPS_URL"|sed 's/^[ \t]*//g'|sed -e '/^\/\//d'|grep "define('XOOPS_URL'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "XOOPS_URL: \e[32m$XOOPS_URL\e[0m"

TAD_ADM_VERSION_CURRENT=$(cat modules/tad_adm/xoops_version.php |grep "'version"|cut -d"=" -f 2|cut -d";" -f 1|cut -d"'" -f 2)
echo -e "[模組]站長工具箱 版本: \e[32m${TAD_ADM_VERSION_CURRENT}\e[0m"
TAD_ADM_VERSION_CURRENT=$(echo $TAD_ADM_VERSION_CURRENT|sed 's/\.//g')
TAD_ADM_VERSION_CURRENT=$(($TAD_ADM_VERSION_CURRENT))
if [ $TAD_ADM_VERSION_CURRENT -lt 100 ]
then
    TAD_ADM_VERSION_CURRENT=$(($TAD_ADM_VERSION_CURRENT*10))
fi
#echo $TAD_ADM_VERSION_CURRENT

TADTOOLS_VERSION_CURRNET=$(cat modules/tadtools/xoops_version.php |grep "'version"|cut -d"=" -f 2|cut -d";" -f 1|cut -d"'" -f 2)
echo -e "[模組]tadtools 版本: \e[32m${TADTOOLS_VERSION_CURRNET}\e[0m"
TADTOOLS_VERSION_CURRNET=$(echo $TADTOOLS_VERSION_CURRNET|sed 's/\.//g')
TADTOOLS_VERSION_CURRNET=$(($TADTOOLS_VERSION_CURRNET))
if [ $TADTOOLS_VERSION_CURRNET -lt 100 ]
then
    TADTOOLS_VERSION_CURRNET=$(($TADTOOLS_VERSION_CURRNET*10))
fi
#echo $TADTOOLS_VERSION_CURRNET

XOOPS_VERSION_CURRENT=$(cat include/version.php |grep "'XOOPS_VERSION"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[核心]XOOPS: \e[32m${XOOPS_VERSION_CURRENT}\e[0m"
XOOPS_VERSION_CURRENT=$(echo $XOOPS_VERSION_CURRENT|cut -d"." -f 3) #只留下第三個數字
XOOPS_VERSION_CURRENT=$(($XOOPS_VERSION_CURRENT))
#echo $XOOPS_VERSION_CURRENT


####################### 進行更新 ########################
TADTOOLS_VERSION=3.26
TADTOOLS_URL="http://120.115.2.90/modules/tad_modules/index.php?op=tufdl&files_sn=1961#tadtools_3.26_20190509.zip"

TAD_ADM_VERSION=2.81
TAD_ADM_URL="http://120.115.2.90/modules/tad_modules/index.php?op=tufdl&files_sn=1962#tad_adm_2.81_20190509.zip"

cd "$XOOPS_ROOT_PATH/modules"


if [ $TAD_ADM_VERSION_CURRENT -lt 281 ]; then
  echo "進行更新[模組]站長工具箱 ==> 2.81"
  echo "下載模組並解開： tad_adm 站長工具箱..."
  if ! [ -f tad_adm_${TAD_ADM_VERSION}.zip ];then
    wget $TAD_ADM_URL -O tad_adm_${TAD_ADM_VERSION}.zip
  fi
  rm -rf tad_adm
  unzip -q tad_adm_${TAD_ADM_VERSION}.zip
  chown -R apache.apache tad_adm
  rm tad_adm_${TAD_ADM_VERSION}.zip
fi

if [ $TADTOOLS_VERSION_CURRNET -lt 326 ]; then
  echo "進行更新[模組]tadtools 工具包 ==> 3.26"
  echo "下載模組並解開： tadtools 工具包..."
  if ! [ -f tadtools_${TADTOOLS_VERSION}.zip ];then
    wget $TADTOOLS_URL -O tadtools_${TADTOOLS_VERSION}.zip
  fi
  rm -rf tadtools
  unzip -q tadtools_${TADTOOLS_VERSION}.zip
  chown -R apache.apache tadtools
  rm tadtools_${TADTOOLS_VERSION}.zip
fi

cd /tmp

if [ ! -f "${XOOPS_ROOT_PATH}/class/xoopsform/renderer/XoopsFormRendererBootstrap4.php" ]; then
  echo "缺少 BootStrap4升級補丁"
  echo "下載更新並解開： BootStrap4升級補丁"
  if ! [ -f bs4_upgrade.zip ];then
    wget 'http://120.115.2.90/modules/tad_modules/xoops.php?op=tufdl&files_sn=1845#bs4_upgrade_20190101.zip' -O bs4_upgrade.zip
  fi
  unzip -q -o bs4_upgrade.zip
  cp -fr htdocs/* ${XOOPS_ROOT_PATH}/
  chown apache.apache ${XOOPS_ROOT_PATH}/class/xoopsform/renderer/XoopsFormRendererBootstrap4.php
  chown apache.apache ${XOOPS_ROOT_PATH}/class/xoopsload.php
  chown apache.apache ${XOOPS_ROOT_PATH}/uploads/bs4_upgrade.txt
  date +"%Y-%m-%d %H:%M:%S" > ${XOOPS_ROOT_PATH}/uploads/xoops_sn_6.txt
fi


if [ $XOOPS_VERSION_CURRENT -lt 9 ]; then
  echo "進行更新[核心]XOOPS  ==> 2.5.9"
fi

echo DONE
