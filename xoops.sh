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

#source lang/en.xoops
source lang/zh_TW.xoops

# Current folder
cur_dir=`pwd`

# Get public IP
function getIP(){
    IP=`ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\." | head -n 1`
    if [[ "$IP" = "" ]]; then
        IP=`curl -s -4 icanhazip.com`
    fi
}

getIP

wget 'http://120.115.2.90/modules/tad_uploader/index.php?op=dlfile&cfsn=108&cat_sn=16&name=xoopscore25-2.5.8_tw_20160529.zip' -O xoops.zip
unzip -q xoops.zip

wget --no-check-certificate https://github.com/tad0616/tadtools/archive/master.zip -O tadtools.zip
unzip -q tadtools.zip
chown -R apache.apache tadtools-master

wget --no-check-certificate https://github.com/tad0616/tad_adm/archive/master.zip -O tad_adm.zip
unzip -q tad_adm.zip
chown -R apache.apache tad_adm-master

#wget --no-check-certificate https://github.com/tad0616/tad_themes/archive/master.zip -O tad_themes.zip
#unzip -q tad_themes.zip
#chown -R apache.apache tad_themes-master


cd XoopsCore25-2.5.8
chown -R apache.apache htdocs

# Choose XOOPS site location type
while true
do
	echo $MSG_CHOOSE_TYPE
	echo -e "\t\e[32m1\e[0m. http://${IP}/"
	echo -e "\t\e[32m2\e[0m. http://${IP}/XOOPS/"
	read -p "$MSG_INPUT_1" SITE_root_type
	[ -z "$SITE_root_type" ] && SITE_root_type=1
	case $SITE_root_type in
		1|2)
		echo ""
		echo "---------------------------"
		echo $MSG_YOU_CHOOSE $SITE_root_type
		echo "---------------------------"
		echo ""
		break
		;;
		*)
		echo $MSG_INPUT_ONLY "1,2"
	esac
done

if [ $SITE_root_type -eq 1 ]; then
	mv /var/www/html /var/www/html_org
	mv htdocs /var/www/html

	cd ..
	mv tadtools-master /var/www/html/modules/tadtools
	mv tad_adm-master /var/www/html/modules/tad_adm

	cd /var/www/html
	mv xoops_* /var/www

	echo ""
	echo $MSG_SETUP_XOOPS_OK
	echo ""
	echo -e $MSG_OPEN_SITE " => http://${IP} " $MSG_TO_FINISH
	echo ""
	echo ""
fi


if [ $SITE_root_type -eq 2 ]; then
	# Set your XOOPS site location
	echo $MSG_INPUT_URL
	echo -e $MSG_YOUR_SITE "http://${IP}/\e[32mXOOPS\e[0m/"
	read -p "$MSG_CHANGE_DEFAULT" SITE_root
	if [ -z $SITE_root ]; then
		SITE_root="XOOPS"
	fi

	mv htdocs /var/www/html/${SITE_root}
	mkdir /var/www/${SITE_root}

	cd ..
	mv tadtools-master /var/www/html/${SITE_root}/modules/tadtools
	mv tad_adm-master /var/www/html/${SITE_root}/modules/tad_adm

	cd /var/www/html/${SITE_root}
	mv xoops_* /var/www/${SITE_root}

	echo ""
	echo $MSG_SETUP_XOOPS_OK
	echo ""
	echo -e $MSG_OPEN_SITE " => http://${IP}/\e[32m${SITE_root}\e[0m/" $MSG_TO_FINISH
	echo $MSG_STEP_4_14
	echo -e "xoops_data ${MSG_DIR}:\e[32m/var/www/${SITE_root}/xoops_data\e[0m"
	echo -e "xoops_lib  ${MSG_DIR}:\e[32m/var/www/${SITE_root}/xoops_lib\e[0m"
	echo ""
	echo ""
	echo ""
fi
