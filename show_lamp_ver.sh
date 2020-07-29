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
      echo "Apache 未安裝 !"
      let HAVE_ERROR+=1
    fi
    echo ""

    echo "=========="
    echo "MySQL  版本"
    echo "=========="
    mysql -V
    if [ $? -ne 0 ];then
      echo "MySQL 未安裝 !"
      let HAVE_ERROR+=2
    fi
    echo ""

    echo "=========="
    echo "PHP    版本"
    echo "=========="
    php -v
    if [ $? -ne 0 ];then
      echo "PHP 未安裝 !"
      let HAVE_ERROR+=4
    fi
    echo ""
    echo ""

    return $HAVE_ERROR
}

show_version


