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
Dump_Xoops_DIR="/root/Dump_Xoops"

get_char()
{
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

get_yes_no()
{
  while true
  do
    echo -n "$1 [y/n]"
    ANSER=$(get_char)
    case $ANSER in
        y|Y)
        echo ""
        if [ $# -ge 2 ]; then
          echo "-----------------------------"
          echo -e "$2"
          echo "-----------------------------"
        fi
        return 1
        break
        ;;
        n|N)
        echo ""
        return 0
        break
        ;;
        *)
        echo -e "\t請輸入 y 或 n"
    esac
  done
}


function get_define()
{
  parse_file=$1
  define_name=$2

  get1=$(cat $1|grep "define(" |sed 's/^[ \t]*//g'|sed -e '/^\/\//d'|sed -e '/^#/d'|sed s/\"/\'/g|sed -e '/XOOPS_TRUST_PATH/d'|grep $define_name)
  if [ $?==0 ];then
    get2=$(echo $get1|cut -d"," -f 2|cut -d"'" -f 2)
    echo $get2
  fi
}

function get_var()
{
  parse_file=$1
  var_name=$2

  get1=$(cat $1|sed s/\"/\'/g|grep \'$var_name|cut -d"=" -f 2|cut -d"'" -f 2)
  echo $get1
}

if [ $# -ge 1 ]; then
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


cd $SEARCH_PATH

XOOPS_ROOT_PATH=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_ROOT_PATH)
XOOPS_VAR_PATH=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_VAR_PATH)
XOOPS_PATH=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_PATH)
XOOPS_URL=$(get_define ${SEARCH_PATH}/mainfile.php XOOPS_URL)
TAD_ADM_VERSION_CURRENT=$(get_var modules/tad_adm/xoops_version.php version)
TADTOOLS_VERSION_CURRNET=$(get_var modules/tadtools/xoops_version.php version)
XOOPS_VERSION_CURRENT=$(get_define ${SEARCH_PATH}/include/version.php XOOPS_VERSION)

if [ -f ${XOOPS_VAR_PATH}/data/secure.php ]; then
  secure_file=${XOOPS_VAR_PATH}/data/secure.php
else
  secure_file=${SEARCH_PATH}/mainfile.php
fi

XOOPS_DB_USER=$(get_define $secure_file XOOPS_DB_USER)
XOOPS_DB_PASS=$(get_define $secure_file XOOPS_DB_PASS)
XOOPS_DB_NAME=$(get_define $secure_file XOOPS_DB_NAME)
XOOPS_DB_PREFIX=$(get_define $secure_file XOOPS_DB_PREFIX)
XOOPS_DB_CHARSET=$(get_define $secure_file XOOPS_DB_CHARSET)
XOOPS_DB_TYPE=$(get_define $secure_file XOOPS_DB_TYPE)

echo -e "\n目前網站版本如下:\n==========================="
echo -e "[設定]XOOPS_ROOT_PATH: \e[32m$XOOPS_ROOT_PATH\e[0m"
echo -e "[設定]XOOPS_VAR_PATH: \e[32m$XOOPS_VAR_PATH\e[0m"
echo -e "[設定]XOOPS_PATH: \e[32m$XOOPS_PATH\e[0m"
echo -e "[設定]XOOPS_URL: \e[32m$XOOPS_URL\e[0m"
echo -e "[模組]站長工具箱 版本: \e[32m${TAD_ADM_VERSION_CURRENT}\e[0m"
echo -e "[模組]tadtools 版本: \e[32m${TADTOOLS_VERSION_CURRNET}\e[0m"
echo -e "[核心]XOOPS: \e[32m${XOOPS_VERSION_CURRENT}\e[0m"
echo -e "[設定]XOOPS_DB_USER 資料庫使用者: \e[32m${XOOPS_DB_USER}\e[0m"
echo -e "[設定]XOOPS_DB_PASS 資料庫密碼: \e[32m${XOOPS_DB_PASS}\e[0m"
echo -e "[設定]XOOPS_DB_NAME 資料庫名稱: \e[32m${XOOPS_DB_NAME}\e[0m"
echo -e "[設定]XOOPS_DB_PREFIX 資料庫前置碼: \e[32m${XOOPS_DB_PREFIX}\e[0m"
echo -e "[設定]XOOPS_DB_CHARSET 資料庫編碼: \e[32m${XOOPS_DB_CHARSET}\e[0m"
echo -e "[設定]XOOPS_DB_TYPE 資料庫: \e[32m${XOOPS_DB_TYPE}\e[0m"

echo -e "[設定]XOOPS_ROOT_PATH: \e[32m$XOOPS_ROOT_PATH\e[0m"
if [ $XOOPS_ROOT_PATH != $SEARCH_PATH ]; then
  echo "XOOPS_ROOT_PATH 和實際的網站放置的資料夾不同，可能是使用 ln -s 符號連結!"
  #exit 1002
fi

if [ -z "$XOOPS_ROOT_PATH" -o -z "$XOOPS_VAR_PATH" -o -z "$XOOPS_PATH" -o -z "$XOOPS_DB_USER" -o -z "$XOOPS_DB_PASS" -o -z "$XOOPS_DB_NAME" ]; then
  echo -e "\e[31m以上獲取的資料不完整，無法進行備份網站的工作，執行中斷\e[0m"
  exit 1
fi

if [ $# -ge 2 ]; then
  Dump_Xoops_DIR=$2
  # echo -e "\e[33m開始備份網站各項資料到 $Dump_Xoops_DIR\e[0m"
fi

get_yes_no "你確定要執行備份工作?" "\e[33m開始備份網站各項資料到 $Dump_Xoops_DIR\e[0m"
if [ $? -eq 0 ]; then exit 1; fi

if ! [ -d $Dump_Xoops_DIR ]; then
  mkdir $Dump_Xoops_DIR -p
fi

echo 壓縮 $XOOPS_ROOT_PATH 請稍等 1~3 分鐘 ...
cd $XOOPS_ROOT_PATH
tar zcf $Dump_Xoops_DIR/xoops_A.tgz .
echo 已經壓縮為 $Dump_Xoops_DIR/xoops_A.tgz

echo 壓縮 $XOOPS_VAR_PATH 請稍等...
cd $XOOPS_VAR_PATH/..
tar zcf $Dump_Xoops_DIR/xoops_B.tgz xoops_data
echo 已經壓縮為 $Dump_Xoops_DIR/xoops_B.tgz

echo 壓縮 $XOOPS_PATH 請稍等...
cd $XOOPS_PATH/..
tar zcf $Dump_Xoops_DIR/xoops_C.tgz xoops_lib
echo 已經壓縮為 $Dump_Xoops_DIR/xoops_C.tgz

echo 匯出資料庫，正在執行以下程式，請稍等 1~3 分鐘 ...
echo mysqldump --lock-tables=false -u $XOOPS_DB_USER -p$XOOPS_DB_PASS $XOOPS_DB_NAME
mysqldump --lock-tables=false -u $XOOPS_DB_USER -p$XOOPS_DB_PASS $XOOPS_DB_NAME>$Dump_Xoops_DIR/xoops_db.sql
echo 匯出資料庫為 $Dump_Xoops_DIR/xoops_db.sql

echo XOOPS_ROOT_PATH=$XOOPS_ROOT_PATH >$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_VAR_PATH=$XOOPS_VAR_PATH >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_PATH=$XOOPS_PATH >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_URL=$XOOPS_URL >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_DB_USER=$XOOPS_DB_USER >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_DB_PASS=$XOOPS_DB_PASS >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_DB_NAME=$XOOPS_DB_NAME >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_DB_PREFIX=$XOOPS_DB_PREFIX >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_DB_CHARSET=$XOOPS_DB_CHARSET >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_DB_TYPE=$XOOPS_DB_TYPE >>$Dump_Xoops_DIR/xoops_var.def
echo XOOPS_VERSION_CURRENT=$XOOPS_VERSION_CURRENT >>$Dump_Xoops_DIR/xoops_var.def
echo TAD_ADM_VERSION_CURRENT=$TAD_ADM_VERSION_CURRENT >>$Dump_Xoops_DIR/xoops_var.def
echo TADTOOLS_VERSION_CURRNET=$TADTOOLS_VERSION_CURRNET >>$Dump_Xoops_DIR/xoops_var.def
echo 匯出上列各項資料到 $Dump_Xoops_DIR/xoops_var.def

echo ======================================
echo 已經全部匯出檔案如下：
echo ======================================
ls --color=auto -lh $Dump_Xoops_DIR

cd $Dump_Xoops_DIR
echo ======================================
echo 你可以傳送以上的檔案到遠端伺服器，複製以下的指令，修改後再執行
echo -e "\e[33mcd $Dump_Xoops_DIR; scp -P 10??? xoops_A.tgz xoops_B.tgz xoops_C.tgz xoops_db.sql xoops_var.def chc@163.23.200.43:.\e[0m"

