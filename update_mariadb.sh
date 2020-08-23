#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS
#   Description:
#   Author: 邱顯錫 (Chiou, Hsienhsi)
#   Intro:  https://github.com/xichiou/lamp-xoops
#===============================================================================================

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


function update_mariadb()
{
	
	cp /root/lamp-xoops-master/include/MariaDB.repo /etc/yum.repos.d/
	yum -y remove mariadb mariadb-server
	if [ $1 == 2 ];then 
	   echo rpm -e --nodeps galera
	fi  
	yum clean all
	yum makecache
	yum -y install mariadb mariadb-server
	# 關閉 STRICT 模式
	echo [mysqld] >> /etc/my.cnf
	echo #default-storage-engine=MyISAM >> /etc/my.cnf
	echo sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\" >> /etc/my.cnf
	systemctl start mariadb
	systemctl enable mariadb

	clear
	mysql_upgrade -uroot -p`cat /root/mysql_password.txt`
	if [ $? -ne 0 ];then
	  #資料表更新失敗
	  HAVE_ERROR=1
    fi
	
}

clear
    
HAVE_ERROR=0

ML=`mysql -V`
if [ $? -ne 0 ];then
  echo "MariaDB 未安裝 !"
fi

#echo $ML
get1=$(echo $ML|grep 'MariaDB')
if [ $? != 0 ];then
	echo "這個更新只適用於 MariaDB !"
fi

get1=$(echo $ML|grep '5.5.')
if [ $? == 0 ];then
	get_yes_no "你確定要執行升級工作，從 5.5 升級到 10.4 ?" "\e[33m 開始升級 \e[0m"
	if [ $? -eq 0 ]; then exit 1; fi
	update_mariadb 1
else
	get1=$(echo $ML|grep '10.3.')
	if [ $? == 0 ];then
		get_yes_no "你確定要執行升級工作，從 10.3 升級到 10.4 ?" "\e[33m 開始升級 \e[0m"
		if [ $? -eq 0 ]; then exit 1; fi
		update_mariadb 2
	else
        echo "已經是 10.4 不需要升級"	
		echo ""
	fi	
fi


echo "=================="
echo "目前 MariaDB  版本"
echo "=================="
mysql -V
if [ $? -ne 0 ];then
  echo "MariaDB 未能成功升級 !"
fi

if [ $HAVE_ERROR == 1 ];then
  echo ""
  echo "資料表更新失敗，請自行下指令更新："
  echo "mysql_upgrade -uroot -p資料庫密碼"
fi
	
echo ""	
