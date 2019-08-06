#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS
#   Description:
#   Author: 邱顯錫 (Chiou, Hsienhsi)
#   Intro:  https://github.com/xichiou/lamp-xoops
#===============================================================================================

TADTOOLS_VERSION=3.3
TADTOOLS_URL="http://campus-xoops.tn.edu.tw/modules/tad_modules/index.php?op=tufdl&files_sn=2056#tadtools_3.3_20190805.zip"

TAD_ADM_VERSION=2.83
TAD_ADM_URL="http://campus-xoops.tn.edu.tw/modules/tad_modules/index.php?op=tufdl&files_sn=2049#tad_adm_2.83_20190728.zip"

#TAD_THEMES_VERSION=5.6
#TAD_THEMES_URL="https://campus-xoops.tn.edu.tw/modules/tad_modules/index.php?op=tufdl&files_sn=2043#tad_themes_5.6_20190725.zip"

clear

#source lang/en.xoops
source lang/zh_TW.xoops

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

getIP

Public_IP=`curl -s -4 icanhazip.com`

# 檢查是否為虛擬機
if [ "$Public_IP" == "163.23.200.43" ]; then
  IP_4=$(echo $IP|cut -d"." -f 4)
  IP_4=$((IP_4))
  CHC_PORT=$(($IP_4+20000))
  URL="${Public_IP}:${CHC_PORT}"
else
  CHC_PORT=0
  URL=$IP
fi


rm -rf XoopsCore25-2.5.10
rm -rf tadtools
rm -rf tad_adm
#rm -rf tad_themes

echo "下載 XOOPS 2.5.10 安裝程式並解開..."
if ! [ -f xoops-2.5.10.zip ];then
	wget 'http://campus-xoops.tn.edu.tw/modules/tad_uploader/index.php?op=dlfile&cfsn=1780&cat_sn=16&name=xoopscore25-2.5.10.zip' -O xoops-2.5.10.zip
	if [ $? -ne 0 ];then
	  rm -f xoops-2.5.10.zip
          echo "主網站下載失敗，改從彰化縣網下載!"
	  wget 'http://163.23.200.9/uploads/xoops-2.5.10.zip' -O xoops-2.5.10.zip
	  if [ $? -ne 0 ];then
	    rm -f xoops-2.5.10.zip
	    echo "彰化縣網下載失敗，安裝中斷，請稍後再安裝看看!"
            exit 2;
	  fi
  fi

fi
unzip -q xoops-2.5.10.zip
chown -R apache.apache XoopsCore25-2.5.10

echo "下載模組並解開： tadtools 工具包..."
if ! [ -f tadtools_${TADTOOLS_VERSION}.zip ];then
	wget $TADTOOLS_URL -O tadtools_${TADTOOLS_VERSION}.zip
fi
unzip -q tadtools_${TADTOOLS_VERSION}.zip
chown -R apache.apache tadtools

echo "下載模組並解開： tad_adm 站長工具箱..."
if ! [ -f tad_adm_${TAD_ADM_VERSION}.zip ];then
	wget $TAD_ADM_URL -O tad_adm_${TAD_ADM_VERSION}.zip
fi
unzip -q tad_adm_${TAD_ADM_VERSION}.zip
chown -R apache.apache tad_adm

# echo "下載模組並解開： Tad Themes 佈景管理..."
# if ! [ -f tad_themes_${TAD_THEMES_VERSION}.zip ];then
# 	wget $TAD_THEMES_URL -O tad_themes_${TAD_THEMES_VERSION}.zip
# fi
# unzip -q tad_themes_${TAD_THEMES_VERSION}.zip
# chown -R apache.apache tad_themes

#wget --no-check-certificate https://github.com/tad0616/tad_themes/archive/master.zip -O tad_themes.zip
#unzip -q tad_themes.zip
#chown -R apache.apache tad_themes-master


cd XoopsCore25-2.5.10

# Choose XOOPS site location type
while true
do
	echo ""
	echo ""
	echo -e $MSG_CHOOSE_TYPE
	echo -e $MSG_CHOOSE_TYPE_1
	echo -e $MSG_CHOOSE_TYPE_2
	echo ""
	echo "請選擇網站類型："
	echo -e "\t\e[32m1\e[0m. http://${IP}/"
	echo -e "\t\e[32m2\e[0m. http://${IP}/XOOPS/"
	read -p "$MSG_INPUT_1" SITE_root_type
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

echo ""
echo ""

# Choose XOOPS sendmail type
while true
do
	echo $MSG_SENDMAIL_TYPE
	echo -e "\t\e[32m1\e[0m. Gmail"
	echo -e "\t\e[32m2\e[0m." $MSG_SENDMAIL
	read -p "$MSG_INPUT_1" SITE_sendmail_type
	[ -z "$SITE_sendmail_type" ] && SITE_sendmail_type=1
	case $SITE_sendmail_type in
		1|2)
		#echo ""
		#echo "---------------------------"
		#echo $MSG_YOU_CHOOSE $SITE_sendmail_type
		#echo "---------------------------"
		#echo ""
		break
		;;
		*)
		echo $MSG_INPUT_ONLY "1,2"
	esac
done

if [ $SITE_sendmail_type -eq 1 ]; then
	sed -i 's/^.*public $SMTP_PORT.*=.*/public $SMTP_PORT =587; \/\/Gmail/g' htdocs/class/mail/phpmailer/class.smtp.php
fi

echo ""
echo ""


if [ $SITE_root_type -eq 1 ]; then
	TTIME=`date "+%Y%m%d_%H%M%S"`
	if [ -f /var/www/html/mainfile.php ]; then
		echo -e "\n注意!!這台伺服器 /var/www/html 網站根目錄已經有網站，"
		read -p " 由此腳本幫你搬移原網站到別處，然後再安裝新網站嗎? [y/n]" yn
		if [ "${yn}" != "Y" ] && [ "${yn}" != "y" ]; then
			echo 取消安裝
			exit 3
		fi
		echo -e "\n搬移舊網站設定檔到 /var/www/bak_xoops_data_lib/${TTIME}_move"
		mkdir -p /var/www/bak_xoops_data_lib/${TTIME}_move
		mv /var/www/xoops_* /var/www/bak_xoops_data_lib/${TTIME}_move
	fi

	echo -e "\n搬移舊網站到 /var/www/html/${TTIME}_move"
	mv /var/www/html /var/www/html_${TTIME}_move
	mv htdocs /var/www/html
	mv -f xoops_* /var/www


	cd ..
	mv tadtools /var/www/html/modules/tadtools
	mv tad_adm /var/www/html/modules/tad_adm
	mv tad_themes /var/www/html/modules/tad_themes

  if [ -d "/root/DB_Backup/${IP}" ]; then
    echo "Directory /root/DB_Backup/${IP} exists."
		/usr/bin/ln -s /var/www/html/uploads /root/DB_Backup/${IP}/html
  fi

	echo ""
	echo $MSG_SETUP_XOOPS_OK
	echo ""
	if [ $CHC_PORT -gt 0 ]; then
		echo -e "\n這台主機是彰化縣網路虛擬機\n"
  fi
	echo -e $MSG_OPEN_SITE " => \e[32mhttp://${URL}\e[0m " $MSG_TO_FINISH
	echo ""
	echo ""
fi


if [ $SITE_root_type -eq 2 ]; then
	# Set your XOOPS site location
	echo $MSG_INPUT_URL
	echo -e $MSG_YOUR_SITE "http://${URL}/\e[32mXOOPS\e[0m/"
	read -p "$MSG_CHANGE_DEFAULT" SITE_root
	if [ -z $SITE_root ]; then
		SITE_root="XOOPS"
	fi

	mv htdocs /var/www/html/${SITE_root}
	mkdir /var/www/${SITE_root}
	mv xoops_* /var/www/${SITE_root}

	cd ..
	mv tadtools /var/www/html/${SITE_root}/modules/tadtools
	mv tad_adm /var/www/html/${SITE_root}/modules/tad_adm
	mv tad_themes /var/www/html/${SITE_root}/modules/tad_themes


	if [ -d "/root/DB_Backup/${IP}" ]; then
		echo "Directory /root/DB_Backup/${IP} exists."
		/usr/bin/ln -s /var/www/html/${SITE_root}/uploads /root/DB_Backup/${IP}/html/${SITE_root}_uploads
  fi

	echo ""
	echo $MSG_SETUP_XOOPS_OK
	echo ""
	echo -e $MSG_OPEN_SITE " => http://${URL}/\e[32m${SITE_root}\e[0m/" $MSG_TO_FINISH
	echo -e "請注意：當你開啟上述網址進行安裝到第4步驟時，必須填寫以下資料"
	echo -e "xoops_data ${MSG_DIR}:\e[32m/var/www/${SITE_root}/xoops_data\e[0m"
	echo -e "xoops_lib  ${MSG_DIR}:\e[32m/var/www/${SITE_root}/xoops_lib\e[0m"
	echo ""
	echo ""
fi
