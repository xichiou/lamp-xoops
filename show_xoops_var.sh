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

function get_define()
{
  parse_file=$1
  define_name=$2

  get1=$(cat $1|grep "define(" |sed 's/^[ \t]*//g'|sed -e '/^\/\//d'|sed -e '/^#/d'|sed s/\"/\'/g |grep $define_name)
  get2=$(echo $get1|cut -d"," -f 2|cut -d"'" -f 2)
  echo $get2
}

function get_var()
{
  parse_file=$1
  var_name=$2

  get1=$(cat $1|sed s/\"/\'/g|grep \'$var_name|cut -d"=" -f 2|cut -d"'" -f 2)
  echo $get1
}

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

XOOPS_ROOT_PATH=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_ROOT_PATH)
echo -e "[設定]XOOPS_ROOT_PATH: \e[32m$XOOPS_ROOT_PATH\e[0m"
if [ $XOOPS_ROOT_PATH != $SEARCH_PATH ]; then
  echo "XOOPS_ROOT_PATH 和實際的網站資料夾不同，可能無法運作!"
  #exit 1002
fi


XOOPS_VAR_PATH=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_VAR_PATH)
echo -e "[設定]XOOPS_VAR_PATH: \e[32m$XOOPS_VAR_PATH\e[0m"

XOOPS_PATH=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_PATH)
echo -e "[設定]XOOPS_PATH: \e[32m$XOOPS_PATH\e[0m"

XOOPS_URL=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_URL)
echo -e "[設定]XOOPS_URL: \e[32m$XOOPS_URL\e[0m"

TAD_ADM_VERSION_CURRENT=$(get_var modules/tad_adm/xoops_version.php version)
echo -e "[模組]站長工具箱 版本: \e[32m${TAD_ADM_VERSION_CURRENT}\e[0m"

TADTOOLS_VERSION_CURRNET=$(get_var modules/tadtools/xoops_version.php version)
echo -e "[模組]tadtools 版本: \e[32m${TADTOOLS_VERSION_CURRNET}\e[0m"

XOOPS_VERSION_CURRENT=$(get_define ${SEARCH_PATH}/include/version.php XOOPS_VERSION)
echo -e "[核心]XOOPS: \e[32m${XOOPS_VERSION_CURRENT}\e[0m"

if [ -f ${XOOPS_VAR_PATH}/data/secure.php ]; then
  secure_file=${XOOPS_VAR_PATH}/data/secure.php
else
  secure_file=${SEARCH_PATH}/mainfile.php
fi

XOOPS_DB_USER=$(get_define $secure_file XOOPS_DB_USER)
echo -e "[設定]XOOPS_DB_USER 資料庫使用者: \e[32m${XOOPS_DB_USER}\e[0m"

XOOPS_DB_PASS=$(get_define $secure_file XOOPS_DB_PASS)
echo -e "[設定]XOOPS_DB_PASS 資料庫密碼: \e[32m${XOOPS_DB_PASS}\e[0m"

XOOPS_DB_NAME=$(get_define $secure_file XOOPS_DB_NAME)
echo -e "[設定]XOOPS_DB_NAME 資料庫名稱: \e[32m${XOOPS_DB_NAME}\e[0m"

XOOPS_DB_PREFIX=$(get_define $secure_file XOOPS_DB_PREFIX)
echo -e "[設定]XOOPS_DB_PREFIX 資料庫前置碼: \e[32m${XOOPS_DB_PREFIX}\e[0m"

XOOPS_DB_CHARSET=$(get_define $secure_file XOOPS_DB_CHARSET)
echo -e "[設定]XOOPS_DB_CHARSET 資料庫編碼: \e[32m${XOOPS_DB_CHARSET}\e[0m"

XOOPS_DB_TYPE=$(get_define $secure_file XOOPS_DB_TYPE)
echo -e "[設定]XOOPS_DB_TYPE 資料庫: \e[32m${XOOPS_DB_TYPE}\e[0m"

