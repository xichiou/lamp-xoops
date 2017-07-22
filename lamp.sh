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
    IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[1-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
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
    clear
    echo ""
    echo $MSG_LAMP_OK
    echo $MSG_MYSQL_PASSWORD $dbrootpwd
    echo $MSG_SAVE_MYSQL_PASSWORD
    echo $dbrootpwd >> /root/mysql_password.txt
    echo ""

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
    read -p "(直接按下ENTER採用內定密碼: db9999):" dbrootpwd
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
    read -p "請輸入數字:(直接按下ENTER採用內定值 2) " PHP_version
    [ -z "$PHP_version" ] && PHP_version=2
    case $PHP_version in
        1|2)
        #echo ""
        #echo "---------------------------"
        #echo "你選擇 = $PHP_version                  "
        #echo "---------------------------"
        #echo ""
        break
        ;;
        *)
        echo $MSG_MUST_NUM "1,2"
    esac
    done

    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }

    #echo ""
    #echo "建議關閉這台伺服器 IPV6 網路功能，你要關閉? [Y/n]"
    #char=`get_char`
    #if [[ $char = "Y" || $char = "y" || $char = "" ]]
    #then
    # echo "關閉 IPV6"
    # disable_ipv6
    #fi


    echo "使用 Google 雲端硬碟備份你的資料庫嗎? [Y/n]"
    char=`get_char`
    if [[ $char = "Y" || $char = "y" || $char = "" ]]
    then
      echo "使用 Google 雲端硬碟備份你的資料庫"
      use_grive="Y"
    else
      use_grive="N"
    fi
    echo ""


    echo ""
    echo "按下任一按鍵開始安裝...或是按下 Ctrl+C 取消安裝"
    char=`get_char`


    yum -y install unzip wget
    yum -y install epel-release
    wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    rpm -Uvh remi-release-7*.rpm

    if [ $use_grive = "Y" ]
    then
      yum -y install grive2
      cls
      echo ""
      echo ""
      echo "設定資料庫備份執行檔 backup_db.sh"
      sed -i "s/\/root\/DB_Backup/\/root\/DB_Backup\/$IP\/MySQL/g" include/backup_db.sh
      sed -i "s/#\/usr\/bin\/grive/\/usr\/bin\/grive -s $IP/g" include/backup_db.sh
      echo "資料庫備份在 /root/DB_Backup/$IP/MySQL"
      mkdir "/root/DB_Backup/$IP/MySQL" -p
      mkdir "/root/DB_Backup/$IP/html" -p
      echo "準備認證 Google雲端硬碟，請"
      echo "參考網站說明操作 https://github.com/xichiou/lamp-xoops"

      cd /root/DB_Backup
      /usr/bin/grive -a -s $IP
      cd -
      echo ""
      echo "如果看到上面有 sync \"./$IP\" 的訊息，表示備份到 Google雲端硬碟 的設定是成功的 !!"
      sleep 5
    fi

    if ! grep 'backup_db.sh' /etc/crontab; then
        cp include/backup_db.sh /root
        chmod +x /root/backup_db.sh
      echo '5 1 * * * root /root/backup_db.sh > /dev/null 2>&1' >>/etc/crontab
    fi


    yum -y install vim-enhanced
    echo "alias vi='vim'" >> /etc/profile
    echo "set nu" >> /etc/vimrc
    source /etc/profile

    yum -y install ntp
    ntpdate -d tick.stdtime.gov.tw

    if ! grep 'ntpdate' /etc/crontab; then
        echo '0 * * * *  root /usr/sbin/ntpdate watch.stdtime.gov.tw > /dev/null 2>&1' >>/etc/crontab
    fi

    if ! grep 'yum' /etc/crontab; then
    	echo '5 3 * * * root /usr/bin/yum -y update > /var/tmp/yum_upadte.log 2>&1' >>/etc/crontab
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
     remi-php70.repo
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi-php70.repo
        sed -i '/php56]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi.repo
    fi

    if [ $PHP_version -eq 2 ]; then
        sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/remi.repo
        sed -i '/php70]/,/gpgkey/s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php70.repo
    fi

    yum -y install php php-gd php-mysql php-mcrypt

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


install_lamp
