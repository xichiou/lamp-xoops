## 以root 最高權限登入CentOS系統，執行以下指令

    yum install -y unzip wget
    wget --no-check-certificate https://github.com/xichiou/lamp-xoops/archive/master.zip -O lamp-xoops.zip
    unzip lamp-xoops.zip
    cd lamp-xoops-master/
    chmod +x *.sh

### 安裝 LAMP

    ./lamp.sh

### 安裝 XOOPS

    ./xoops.sh

### 設定 Grive，同步資料庫到雲端

    cd /root/DB_Backup
    /usr/bin/grive –a
    ![grive -a](imaages/grive_auth.png)

    登入 Gmail，驗證 Grive ，讓 Grive 可以存取 Google Drive
