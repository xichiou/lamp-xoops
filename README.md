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

### lamp.sh 安裝過程中，讓 Grive 可以存取 Google Drive，同步資料庫到雲端

![grive -a](https://github.com/xichiou/lamp-xoops/blob/master/images/grive-a.png)

    登入 Gmail，驗證 Grive，取得授權碼，再貼回上圖

![允許](https://github.com/xichiou/lamp-xoops/blob/master/images/grive_auth.png)
![取得授權碼](https://github.com/xichiou/lamp-xoops/blob/master/images/grive_auth-2.png)


