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


# Get public IP
function getIP(){
    #IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[1-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
    IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^10\.|^127\.|^255\." | head -n 1`
    if [[ "$IP" = "" ]]; then
        IP=`curl -s -4 icanhazip.com`
    fi
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

# Pre-installation settings
function install_samba(){
    echo ""
    echo "#############################################################"
    echo "# Grive 自動安裝腳本 for CentOS                                #"
    echo "# 簡介: https://github.com/xichiou/lamp-xoops                #"
    echo "# 作者: 邱顯錫 <hsienhsi@gmail.com>                           #"
    echo "#############################################################"
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




    if [ $use_samba = "Y" ]
    then
      yum -y install samba
      clear
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
    fi

}


rootness
disable_selinux

#disable_firewall
systemctl stop firewalld
systemctl disable firewalld

getIP
install_samba
systemctl enable smb
systemctl start smb


echo ""
echo ""
echo ""

echo "Samba 安裝完畢"
echo -e "請在檔案總管的網址列執行  \033[32m\\\\\\\\$IP\033[0m"
echo "你會看到三個目錄"
echo -e "\t1. \033[32mall_for_root\033[0m 這個目錄可以看到伺服器上全部的檔案，"
echo -e "\t   並且以 root 的身分在上面讀寫"
echo -e "\t2. \033[32mvar_www_for_apache\033[0m 這個目錄可以看到網頁空間 /var/www 上的檔案，"
echo -e "\t   並且以 apache 的身分在上面讀寫"
echo -e "\t3. \033[32m$OS_ADMIN\033[0m 這個目錄是 $OS_ADMIN 的家目錄"
