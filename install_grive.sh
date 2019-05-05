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

# Make sure only root can run our script
function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo $MSG_MUST_ROOT 1>&2
   exit 1
fi
}


# Pre-installation settings
function install_grive(){
    echo ""
    echo "#############################################################"
    echo "# Grive 自動安裝腳本 for CentOS                                #"
    echo "# 簡介: https://github.com/xichiou/lamp-xoops                #"
    echo "# 作者: 邱顯錫 <hsienhsi@gmail.com>                           #"
    echo "#############################################################"
    echo ""

    # Display Public IP
    echo "取得 IP 住址"
    getIP
    echo -e "你的主要 IP 是\t\033[32m$IP\033[0m"
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

    echo ""
    echo ""
    echo "按下任一按鍵開始安裝...或是按下 Ctrl+C 取消安裝"
    char=`get_char`



    if [ $use_grive = "Y" ]
    then
      yum -y install grive2
      clear 
      echo ""
      echo ""
      echo "設定資料庫備份執行檔 backup_db.sh"
      sed "s/\/root\/DB_Backup/\/root\/DB_Backup\/$IP\/MySQL/g" include/backup_db.sh_>include/backup_db.sh
      sed -i "s/#\/usr\/bin\/grive/\/usr\/bin\/grive -s $IP/g" include/backup_db.sh
      echo "資料庫備份在 /root/DB_Backup/$IP/MySQL"
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

      cp include/backup_db.sh /root
      chmod +x /root/backup_db.sh

    fi

}



install_grive

