#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS
#   Description:
#   Author: 邱顯錫 (Chiou, Hsienhsi)
#   Intro:  https://github.com/xichiou/lamp-xoops
#===============================================================================================

clear

#source lang/en.lamp
source lang/zh_TW.lamp

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

# Install LAMP Script
function install_lamp(){
    rootness
    disable_selinux
    disable_root_ssh

    #disable_firewall
    systemctl stop firewalld
    systemctl disable firewalld

    pre_installation_settings
    install_apache
    #install_database
    install_mariadb
    install_php
    install_phpmyadmin

}

# Make sure only root can run our script
function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo $MSG_MUST_ROOT 1>&2
   exit 1
fi
}

# Disable selinux
function disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}

# Disable selinux
function disable_root_ssh(){
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    systemctl reload sshd
}

# Disable IPV6
function disable_ipv6(){
    echo "#disabl ipv6" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

# Pre-installation settings
function pre_installation_settings(){
    echo ""
    echo "#############################################################"
    echo "# LAMP 自動安裝腳本 for CentOS                                #"
    echo "# 簡介: https://github.com/xichiou/lamp-xoops                #"
    echo "# 作者: 邱顯錫 <hsienhsi@gmail.com>                           #"
    echo "#############################################################"
    echo ""

    # Display Public IP
    echo "取得 IP 住址"
    getIP
    echo -e "你的主要 IP 是\t\033[32m$IP\033[0m"
    echo ""

    # Set MySQL root password
    echo "請輸入 MySQL or MariaDB 管理員 root 的密碼:"
    read -p "(直接按下 ENTER 採用預設密碼: db9999):" dbrootpwd
    if [ -z $dbrootpwd ]; then
        dbrootpwd="db9999"
    fi
    echo ""
    echo "---------------------------"
    echo "資料庫密碼 = $dbrootpwd"
    echo "---------------------------"
    echo ""

    # Choose PHP version
    while true
    do
    echo "請選擇 PHP 版本:"
    echo -e "\t\033[32m1\033[0m. 安裝 PHP-5.6"
    echo -e "\t\033[32m2\033[0m. 安裝 PHP-7.0"
    echo -e "\t\033[32m3\033[0m. 安裝 PHP-7.1"
    echo -e "\t\033[32m4\033[0m. 安裝 PHP-7.2"
    echo -e "\t\033[32m5\033[0m. 安裝 PHP-7.3"
    read -p "請輸入數字:(或按下 ENTER 直接選擇 4) " PHP_version
    [ -z "$PHP_version" ] && PHP_version=4
    case $PHP_version in
        1)
        #echo ""
        echo "---------------------------"
        echo "你選擇安裝 PHP-5.6"
        echo "---------------------------"
        #echo ""
        break
        ;;
        2)
        #echo ""
        echo "---------------------------"
        echo "你選擇安裝 PHP-7.0"
        echo "---------------------------"
        #echo ""
        break
        ;;
        3)
        #echo ""
        echo "---------------------------"
        echo "你選擇安裝 PHP-7.1"
        echo "---------------------------"
        #echo ""
        break
        ;;
        4)
        #echo ""
        echo "---------------------------"
        echo "你選擇安裝 PHP-7.2"
        echo "---------------------------"
        #echo ""
        break
        ;;
        5)
        #echo ""
        echo "---------------------------"
        echo "你選擇安裝 PHP-7.3"
        echo "---------------------------"
        #echo ""
        break
        ;;
        *)
        echo $MSG_MUST_NUM "1,2,3,4,5"
    esac
    done

    echo ""
    echo ""

    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }


    # disable_ipv6 ?
    while true
    do
    read -p "關閉這台伺服器 IPV6 網路功能，你要關閉? [y/n]" ANSER
    case $ANSER in
        y|Y)
        echo "-----------------------------"
        echo "你選擇關閉這台伺服器 IPV6 的網路!"
        echo "-----------------------------"
        disable_ipv6
        break
        ;;
        n|N)
        break
        ;;
        *)
        echo "請輸入 Y 或 N"
        echo ""
    esac
    done
    echo ""
    echo ""


    # Install Samba ?
    while true
    do
    read -p "使用網路芳鄰嗎? [y/n]" ANSER
    case $ANSER in
        y|Y)
        use_samba="Y"
        echo "-------------------------------------"
        echo "你選擇啟用網路芳鄰!                     "
        echo "-------------------------------------"
        break
        ;;
        n|N)
        use_samba="N"
        break
        ;;
        *)
        echo "請輸入 Y 或 N"
        echo ""
    esac
    done
    echo ""
    echo ""


    # Google Drive ?
    while true
    do
    read -p "使用 Google 雲端硬碟備份你的資料庫嗎? [y/n]" ANSER
    case $ANSER in
        y|Y)
        use_grive="Y"
        echo "-------------------------------------"
        echo "你選擇使用 Google 雲端硬碟備份你的資料庫 !"
        echo "-------------------------------------"
        break
        ;;
        n|N)
        use_grive="N"
        break
        ;;
        *)
        echo "請輸入 Y 或 N"
        echo ""
    esac
    done

    echo ""
    echo ""
    echo "按下任一按鍵開始安裝...或是按下 Ctrl+C 取消安裝"
    char=`get_char`


    yum -y install unzip wget
    yum -y install epel-release
    #wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    wget --no-check-certificate https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    rpm -Uvh remi-release-7*.rpm

    if [ $use_grive = "Y" ]
    then
      yum -y install grive2
      clear
      echo ""
      echo ""
      echo "設定資料庫備份執行檔 backup_db.sh"
      sed "s/\/root\/DB_Backup/\/root\/DB_Backup\/$IP\/MySQL/g" include/backup_db.sh_>include/backup_db.sh
      sed -i "s/#\/usr\/bin\/grive/\/usr\/bin\/grive -s $IP/g" include/backup_db.sh
      echo "資料備份在 /root/DB_Backup/$IP/MySQL"
      mkdir "/root/DB_Backup/$IP/MySQL" -p
      mkdir "/root/DB_Backup/$IP/html" -p
      echo "準備認證 Google雲端硬碟，請"
      echo "參考網站說明操作 https://github.com/xichiou/lamp-xoops"

      cd /root/DB_Backup

      while true
      do
        /usr/bin/grive -V -a -s $IP
        if [ $? = 0 ]
        then
         echo "Google 雲端硬碟認證成功!"
         sleep 5
         break
        fi
        echo ""
        echo "認證失敗，請重新認證，或是按下 Ctrl+C 取消安裝"
      done

      cd -
      #echo ""
      #echo "如果看到上面有 sync \"./$IP\" 的訊息，表示備份到 Google雲端硬碟 的設定是成功的 !!"
      #sleep 5
    fi

    if ! grep 'backup_db.sh' /etc/crontab; then
        cp include/backup_db.sh /root
        chmod +x /root/backup_db.sh
        CRONTAB_H=$(($RANDOM % 6))
        CRONTAB_M=$(($RANDOM % 60))
        echo "$CRONTAB_H $CRONTAB_M * * * root /root/backup_db.sh > /dev/null 2>&1" >>/etc/crontab
    fi


    yum -y install vim-enhanced
    echo "alias vi='vim'" >> /etc/profile
    echo "set nu" >> /etc/vimrc
    source /etc/profile

    yum -y install ntp
    ntpdate -d time.stdtime.gov.tw

    if ! grep 'ntpdate' /etc/crontab; then
        echo '0 * * * *  root /usr/sbin/ntpdate time.stdtime.gov.tw > /dev/null 2>&1' >>/etc/crontab
    fi

    if ! grep 'yum' /etc/crontab; then
        CRONTAB_H=$(($RANDOM % 6))
        CRONTAB_M=$(($RANDOM % 60))
    	echo "$CRONTAB_H $CRONTAB_M * * * root /usr/bin/yum -y update > /var/tmp/yum_upadte.log 2>&1" >>/etc/crontab
    fi

}

# Install Apache
function install_apache(){
    # Install Apache
    echo "開始安裝 Apache..."
    yum -y install httpd
    sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/g' /etc/httpd/conf/httpd.conf
    sed -i 's/DirectoryIndex index.html$/DirectoryIndex index.html index.htm/g' /etc/httpd/conf/httpd.conf
    systemctl enable httpd
    systemctl start httpd
    chown -R apache.apache /var/www
    echo "Apache 安裝完畢"
}

# Install database
function install_database(){
    if [ $DB_version -eq 1 ]; then
        install_mysql
    elif [ $DB_version -eq 2 ]; then
        install_mariadb
    fi
}

# Install MariaDB
function install_mariadb(){
    # Install MariaDB
    echo "開始安裝 MariaDB..."
    yum -y install mariadb mariadb-server
    systemctl enable mariadb
    systemctl start mariadb
    /usr/bin/mysqladmin password $dbrootpwd
    /usr/bin/mysql -uroot -p$dbrootpwd <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$dbrootpwd') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
    echo "MariaDB 安裝完畢!"
}

# Install PHP
function install_php(){
    echo "開始安裝 PHP..."

    if [ $PHP_version -eq 1 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php70.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php71.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php72.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php73.repo
        sed -i '/php56]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi.repo
    fi

    if [ $PHP_version -eq 2 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php71.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php72.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php73.repo
        sed -i '/php70]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php70.repo
    fi

    if [ $PHP_version -eq 3 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php70.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php72.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php73.repo
        sed -i '/php71]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php71.repo
    fi

    if [ $PHP_version -eq 4 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php70.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php71.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php73.repo
        sed -i '/php72]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php72.repo
    fi

    if [ $PHP_version -eq 5 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php70.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php71.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php72.repo
        sed -i '/php73]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php73.repo
    fi

    yum -y install php php-gd php-mysql php-mcrypt php-intl

    sed -i 's/^.*date\.timezone.*=.*/date\.timezone = "Asia\/Taipei"/g' /etc/php.ini
    sed -i 's/^.*display_errors.*=.*/display_errors = On/g' /etc/php.ini
    sed -i 's/^.*max_execution_time.*=.*/max_execution_time = 150/g' /etc/php.ini
    sed -i 's/^.*max_file_uploads.*=.*/max_file_uploads = 300/g' /etc/php.ini
    sed -i 's/^.*max_input_time.*=.*/max_input_time = 120/g' /etc/php.ini
    sed -i 's/^.*max_input_vars.*=.*/max_input_vars = 5000/g' /etc/php.ini
    sed -i 's/^.*memory_limit.*=.*/memory_limit = 240M/g' /etc/php.ini
    sed -i 's/^.*post_max_size.*=.*/post_max_size = 220M/g' /etc/php.ini
    sed -i 's/^.*upload_max_filesize.*=.*/upload_max_filesize = 200M/g' /etc/php.ini

    systemctl reload httpd

    echo "PHP 安裝完畢!"
}

# Install phpmyadmin.
function install_phpmyadmin(){
    yum -y install phpMyAdmin
    #vi /etc/httpd/conf.d/phpMyAdmin.conf
    #line 17: 127.0.0.1 => 127.0.0.1 192 172

    #Start httpd service
    systemctl restart httpd
}

# Install Samba
function install_samba(){
    yum -y install samba
    OS_ADMIN=`cat /etc/passwd |  awk '{FS=":"} $3 == 1000 {print $1}'`
    if [[ -z "$OS_ADMIN" ]]
    then
      OS_ADMIN="root"
    fi
    echo ""
    echo ""
    if ! grep 'var_www' /etc/samba/smb.conf; then
      sed -i "s/os_admin/$OS_ADMIN/g" include/smb.conf.add
      cat include/smb.conf.add >> /etc/samba/smb.conf
    fi
    clear
    echo "您將使用 $OS_ADMIN 這個帳號從網路芳鄰進入伺服器"
    echo "請設定 $OS_ADMIN 這個帳號要使用的新密碼，總共要輸入二次做確認"
    smbpasswd -a $OS_ADMIN

    systemctl enable smb
    systemctl start smb

    echo ""

    echo "Samba 安裝完畢"
    echo -e "請在檔案總管的網址列執行  \033[32m\\\\\\\\$IP\033[0m"
    echo "你會看到三個目錄"
    echo -e "\t1. \033[32mall_for_root\033[0m 這個目錄可以看到伺服器上全部的檔案，"
    echo -e "\t   並且以 root 的身分在上面讀寫"
    echo -e "\t2. \033[32mvar_www_for_apache\033[0m 這個目錄可以看到網頁空間 /var/www 上的檔案，"
    echo -e "\t   並且以 apache 的身分在上面讀寫"
    echo -e "\t3. \033[32m$OS_ADMIN\033[0m 這個目錄是 $OS_ADMIN 的家目錄"

}



function show_version(){
    HAVE_ERROR=0
    echo ""
    echo "以下是已經安裝的軟體版本"
    echo ""
    echo "=========="
    echo "Apache 版本"
    echo "=========="
    httpd -v
    if [ $? -ne 0 ];then
      echo "Apache 安裝失敗 !"
      let HAVE_ERROR+=1
    fi
    echo ""

    echo "=========="
    echo "MySQL  版本"
    echo "=========="
    mysql -V
    if [ $? -ne 0 ];then
      echo "MySQL 安裝失敗 !"
      let HAVE_ERROR+=2
    fi
    echo ""

    echo "=========="
    echo "PHP    版本"
    echo "=========="
    php -v
    if [ $? -ne 0 ];then
      echo "PHP 安裝失敗 !"
      let HAVE_ERROR+=4
    fi
    echo ""
    echo ""

    return $HAVE_ERROR
}


install_lamp

if [ $use_samba = "Y" ]
then
    install_samba
fi

echo ""
echo $MSG_LAMP_OK
echo $MSG_MYSQL_PASSWORD $dbrootpwd
echo $MSG_SAVE_MYSQL_PASSWORD
echo $dbrootpwd >> /root/mysql_password.txt
echo ""

show_version
if [ $? -eq 0 ];then
  while true
  do
  read -p "你要繼續安裝 XOOPS? [y/n]" ANSER
  case $ANSER in
      y|Y)
      echo ""
      echo "開始安裝XOOPS"
      ./xoops.sh
      break
      ;;
      n|N)
      echo ""
      echo "稍後你可以輸入指令 ./xoops.sh 進行安裝 XOOPS"
      break
      ;;
      *)
      echo "請輸入 Y 或 N"
      echo ""
  esac
  done
fi

