#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS
#   Description:
#   Author: 邱顯錫 (Chiou, Hsienhsi)
#   Intro:  https://github.com/xichiou/lamp-xoops
#===============================================================================================

SEARCH_PATH="/var/www/html"

# echo -e "\n\a這個程式腳本幫助您檢查網站運行的版本並且更新："
# echo -e "XOOPS核心==>版本 ${XOOPS_CORE}"
# echo -e "[模組]站長工具箱==>版本 ${TAD_ADM_VERSION}"
# echo -e "[模組][模組]tadtools==>版本 ${TADTOOLS_VERSION}"
# echo ""

if [ $# == 1 ]; then
  SEARCH_PATH=$1
else
  read -p "請輸入網站目錄: $SEARCH_PATH/" SUB_DIR
  if [ "$SUB_DIR" != "" ]; then
    SUB_DIR=$(echo $SUB_DIR | sed -e 's/\/$//')
    SEARCH_PATH="$SEARCH_PATH/$SUB_DIR"
  fi
fi

#echo -e "\n檢查網站目錄 $SEARCH_PATH ..."

if [ ! -f "$SEARCH_PATH/mainfile.php" ]; then
  echo "錯誤! $SEARCH_PATH 目錄下沒有 mainfile.php，請確認網站放在哪個目錄後重新執行"
  exit 1001
fi

echo -e "\n目前網站版本如下:\n====================="

cd $SEARCH_PATH

XOOPS_ROOT_PATH=$(cat mainfile.php |grep "define('XOOPS_ROOT_PATH'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_ROOT_PATH: \e[32m$XOOPS_ROOT_PATH\e[0m"
if [ $XOOPS_ROOT_PATH != $SEARCH_PATH ]; then
  echo "XOOPS_ROOT_PATH 和實際的網站資料夾不同，可能無法運作!"
  #exit 1002
fi


XOOPS_VAR_PATH=$(cat mainfile.php |grep "define('XOOPS_VAR_PATH'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_VAR_PATH: \e[32m$XOOPS_VAR_PATH\e[0m"
XOOPS_PATH=$(cat mainfile.php |grep "define('XOOPS_PATH'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_PATH: \e[32m$XOOPS_PATH\e[0m"

XOOPS_URL=$(cat mainfile.php |grep "define('XOOPS_URL"|sed 's/^[ \t]*//g'|sed -e '/^\/\//d'|grep "define('XOOPS_URL'"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_URL: \e[32m$XOOPS_URL\e[0m"

TAD_ADM_VERSION_CURRENT=$(cat modules/tad_adm/xoops_version.php |grep "'version"|cut -d"=" -f 2|cut -d";" -f 1|cut -d"'" -f 2)
echo -e "[模組]站長工具箱 版本: \e[32m${TAD_ADM_VERSION_CURRENT}\e[0m"


TADTOOLS_VERSION_CURRNET=$(cat modules/tadtools/xoops_version.php |grep "'version"|cut -d"=" -f 2|cut -d";" -f 1|cut -d"'" -f 2)
echo -e "[模組]tadtools 版本: \e[32m${TADTOOLS_VERSION_CURRNET}\e[0m"

XOOPS_VERSION_CURRENT=$(cat include/version.php |grep "'XOOPS_VERSION"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[核心]XOOPS: \e[32m${XOOPS_VERSION_CURRENT}\e[0m"

XOOPS_DB_USER=$(cat ${XOOPS_VAR_PATH}/data/secure.php |grep "'XOOPS_DB_USER"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_DB_USER 資料庫使用者: \e[32m${XOOPS_DB_USER}\e[0m"

XOOPS_DB_PASS=$(cat ${XOOPS_VAR_PATH}/data/secure.php |grep "'XOOPS_DB_PASS"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_DB_PASS 資料庫密碼: \e[32m${XOOPS_DB_PASS}\e[0m"

XOOPS_DB_NAME=$(cat ${XOOPS_VAR_PATH}/data/secure.php |grep "'XOOPS_DB_NAME"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_DB_NAME 資料庫名稱: \e[32m${XOOPS_DB_NAME}\e[0m"

XOOPS_DB_PREFIX=$(cat ${XOOPS_VAR_PATH}/data/secure.php |grep "'XOOPS_DB_PREFIX"|cut -d"," -f 2|cut -d"'" -f 2)
echo -e "[設定]XOOPS_DB_PREFIX 資料庫前置碼: \e[32m${XOOPS_DB_PREFIX}\e[0m"

