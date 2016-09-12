#!/bin/sh
## 本程式用來備份主機資料庫

##備份檔放置位置
BAK_DIR="/root/DB"

## 資料庫實際位置
SQL_DIR="/var/lib/mysql"

## 資料庫壓縮檔前置詞
SQL_ZIP="DB"

TTIME=`date "+%Y%m%d_%H%M%S"`
## 結果會變成 20161005_201851 年月日時分秒

/bin/systemctl stop httpd
/bin/systemctl stop mariadb

if ! [ -d $BAK_DIR ]; then
  mkdir $BAK_DIR
fi

cd $SQL_DIR
cd ..
## echo ${BAK_DIR}/${SQL_ZIP}_${TTIME}.tgz
/bin/tar zcf ${BAK_DIR}/${SQL_ZIP}_${TTIME}.tgz mysql

/bin/systemctl start mariadb
/bin/systemctl start httpd

find $BAK_DIR -ctime +30|xargs rm

echo Done OK
