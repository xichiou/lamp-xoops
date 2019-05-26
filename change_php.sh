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

# Make sure only root can run our script
function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo $MSG_MUST_ROOT 1>&2
   exit 1
fi
}

# Pre-installation settings
function pre_installation_settings(){
    echo ""
    echo "#############################################################"
    echo "# LAMP 自動安裝腳本 for CentOS                                #"
    echo "# 簡介: https://github.com/xichiou/lamp-xoops                #"
    echo "# 作者: 邱顯錫 <xichiou@gmail.com>                            #"
    echo "#############################################################"
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
    echo -e "\t\033[32m6\033[0m. 離開"
    read -p "請輸入數字:(或按下 ENTER 直接選擇 6 離開) " PHP_version
    [ -z "$PHP_version" ] && PHP_version=6
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
        6)
        #echo ""
        echo "---------------------------"
        echo "你選擇離開"
        echo "---------------------------"
        exit
        #echo ""
        break
        ;;
        *)
        echo $MSG_MUST_NUM "1,2,3,4,5,6"
    esac
    done

    echo ""
    echo ""


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


    yum -y remove php php-gd php-mysql php-mcrypt php-intl  php-common
    yum -y install php php-gd php-mysql php-mcrypt php-intl phpMyAdmin

    sed -i 's/^.*date\.timezone.*=.*/date\.timezone = "Asia\/Taipei"/g' /etc/php.ini
    sed -i 's/^.*display_errors.*=.*/display_errors = On/g' /etc/php.ini
    sed -i 's/^.*max_execution_time.*=.*/max_execution_time = 150/g' /etc/php.ini
    sed -i 's/^.*max_file_uploads.*=.*/max_file_uploads = 300/g' /etc/php.ini
    sed -i 's/^.*max_input_time.*=.*/max_input_time = 120/g' /etc/php.ini
    sed -i 's/^.*max_input_vars.*=.*/max_input_vars = 5000/g' /etc/php.ini
    sed -i 's/^.*memory_limit.*=.*/memory_limit = 240M/g' /etc/php.ini
    sed -i 's/^.*post_max_size.*=.*/post_max_size = 220M/g' /etc/php.ini
    sed -i 's/^.*upload_max_filesize.*=.*/upload_max_filesize = 200M/g' /etc/php.ini

    systemctl restart httpd

    echo ""
    echo ""
    echo "PHP 安裝完畢!"
    echo ""
    echo ""

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





rootness

show_version
pre_installation_settings
install_php
show_version
