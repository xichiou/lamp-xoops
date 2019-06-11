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
Restore_Xoops_DIR="/home/chc"
CHC_IP=163.23.200.43


function getIP_Public(){
  IP_Public=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
  if [[ "$IP_Public" = "" ]]; then
      IP_Public=`curl -s -4 icanhazip.com`
  fi
}

function getIP(){
  #IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[1-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
  IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^10\.|^127\.|^255\." | head -n 1`
  if [[ "$IP" = "" ]]; then
      IP=`curl -s -4 icanhazip.com`
  fi
}


function get_web_ip()
{
  getIP_Public
  getIP
  if [ "$IP_Public" = "$CHC_IP" ];then
    WEB_PORT=$(echo $IP|cut -d"." -f 4)
    WEB_PORT=$(($WEB_PORT))
    WEB_PORT=$(($WEB_PORT+20000))
    WEB_IP=${CHC_IP}:$WEB_PORT
  else
    WEB_IP=$IP_Public
  fi

}


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

if [ $# -gt 0 ]; then
  Restore_Xoops_DIR=$1
else
  read -p "請輸入舊網站資料存放目錄: " SUB_DIR
  if [ "$SUB_DIR" == "" ]; then
    echo 必須輸入舊網站資料存放的目錄位置，請重新執行程式
  else
    SUB_DIR=$(echo $SUB_DIR | sed -e 's/\/$//')
    Restore_Xoops_DIR=$SUB_DIR
  fi
fi

if ! [ -f $Restore_Xoops_DIR/xoops_var.def -a -f $Restore_Xoops_DIR/xoops_db.sql -a -f $Restore_Xoops_DIR/xoops_A.tgz -a -f $Restore_Xoops_DIR/xoops_B.tgz -a -f $Restore_Xoops_DIR/xoops_C.tgz ];then
  echo 檔案不齊全，需要 xoops_var.def, xoops_db.sql, xoops_A.tgz, xoops_B.tgz, xoops_C.tgz
  exit 2
fi

get_web_ip
# echo $WEB_IP

# Choose XOOPS site location type
while true
do
  echo ""
  echo ""
  echo -e "請選擇 XOOPS 網址型態:"
  echo -e "第 1 種型態是一台伺服器只裝一個網站"
  echo -e "第 2 種型態是一台伺服器幾個安裝網站，例如以下這兩個網站都是在同一台伺服器上 http://163.23.73.111/sport ， http://163.23.73.111/myhome"
  echo ""
  echo "請選擇："
  echo -e "\t\e[32m1\e[0m. http://${IP}/"
  echo -e "\t\e[32m2\e[0m. http://${IP}/XOOPS/"
  read -p "請輸入數字:(內定值 1) " SITE_root_type
  [ -z "$SITE_root_type" ] && SITE_root_type=1
  case $SITE_root_type in
    1|2)
    #echo ""
    #echo "---------------------------"
    #echo $MSG_YOU_CHOOSE $SITE_root_type
    #echo "---------------------------"
    #echo ""
    break
    ;;
    *)
    echo $MSG_INPUT_ONLY "1,2"
  esac
done

SITE_URL=http://${WEB_IP}
if [ $SITE_root_type -eq 2 ]; then
  # Set your XOOPS site location
  echo "請輸入你的 XOOPS 網站 URL:"
  echo -e "你的 XOOPS 網站 http://${IP}/\e[35mXOOPS\e[0m/"
  read -p "修改 XOOPS 這幾個字，或是採用內定值:XOOPS ==>" SITE_folder
  if [ -z $SITE_folder ]; then
    SITE_folder="XOOPS"
  fi
  SITE_URL=${SITE_URL}/${SITE_folder}
fi

Current_WD=`pwd`

if [ $SITE_root_type -eq 1 ]; then
  DIR_A="/var/www/html"
  DIR_B="/var/www/xoops_data"
  DIR_C="/var/www/xoops_lib"
  TTIME=`date "+%Y%m%d_%H%M%S"`
  mv /var/www /var/www_${TTIME}_move
  mkdir $DIR_A -p
  cd $DIR_A
  tar zxvf $Restore_Xoops_DIR/xoops_A.tgz
  mkdir $DIR_B
  cd $DIR_B/..
  tar zxvf $Restore_Xoops_DIR/xoops_B.tgz
  mkdir $DIR_C
  cd $DIR_C/..
  tar zxvf $Restore_Xoops_DIR/xoops_C.tgz

  chown -R apache.apache /var/www

else
  DIR_A="/var/www/html/$SITE_folder"
  DIR_B="/var/www/$SITE_folder/xoops_data"
  DIR_C="/var/www/$SITE_folder/xoops_lib"
  mkdir $DIR_A -p
  cd $DIR_A
  tar zxf $Restore_Xoops_DIR/xoops_A.tgz
  mkdir $DIR_B -p
  cd $DIR_B/..
  tar zxf $Restore_Xoops_DIR/xoops_B.tgz
  mkdir $DIR_C -p
  cd $DIR_C/..
  tar zxf $Restore_Xoops_DIR/xoops_C.tgz

  chown -R apache.apache $DIR_A
  chown -R apache.apache $DIR_B
  chown -R apache.apache $DIR_C
fi

cd $Current_WD

cp include/mainfile.php_ include/mainfile.php
DIR_A_S=$(echo $DIR_A|sed 's/\//\\\//g')
sed -i "s/__XOOPS_ROOT_PATH/$DIR_A_S/g" include/mainfile.php
DIR_B_S=$(echo $DIR_B|sed 's/\//\\\//g')
sed -i "s/__XOOPS_VAR_PATH/$DIR_B_S/g" include/mainfile.php
DIR_C_S=$(echo $DIR_C|sed 's/\//\\\//g')
sed -i "s/__XOOPS_PATH/$DIR_C_S/g" include/mainfile.php
SITE_URL_S=$(echo $SITE_URL|sed 's/\//\\\//g')
sed -i "s/__XOOPS_URL/$SITE_URL_S/g" include/mainfile.php
cp include/mainfile.php $DIR_A

cp include/secure.php_ include/secure.php
source $Restore_Xoops_DIR/xoops_var.def
mysql_password=$(cat /root/mysql_password.txt)
sed -i "s/__XOOPS_DB_USER/root/g" include/secure.php
sed -i "s/__XOOPS_DB_PASS/$mysql_password/g" include/secure.php
sed -i "s/__XOOPS_DB_NAME/$XOOPS_DB_NAME/g" include/secure.php
sed -i "s/__XOOPS_DB_PREFIX/$XOOPS_DB_PREFIX/g" include/secure.php
cp include/secure.php $DIR_B/data


mysql -u root -p${mysql_password}<<EOF
CREATE DATABASE ${XOOPS_DB_NAME}
  CHARACTER SET utf8
  COLLATE utf8_general_ci;
exit
EOF

mysql -u root -p${mysql_password} ${XOOPS_DB_NAME} < $Restore_Xoops_DIR/xoops_db.sql


echo 復原完畢，請開啟 ${SITE_URL}

