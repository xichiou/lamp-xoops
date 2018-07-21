## 這個專案設計的自動化腳本，幫助你把一部剛安裝好 CentOS 7 作業系統的主機，快速的安裝成 LAMP 網頁伺服器，和裝好 XOOPS 架站軟體，特色如下：

* 安裝過程簡單，只要複製、貼上和輸入資料
* 提供 PHP 5.6、 7.0、 7.1 和 7.2 四種版本供你選擇安裝
* 關閉 root 直接登入 sshd 服務
* 自動更新系統
* 自動校時
* 使用 Google 雲端硬碟備份資料庫和網頁
* 提供網路芳鄰分享資料夾，方便你管理伺服器裡面的檔案

<br/>

## 操作步驟：
### 1. 下載自動化腳本：使用 putty 軟體遠端登入伺服器，切換成 root 最高權限，複製以下指令貼到 putty 軟體內

    cd /root
    yum install -y unzip wget
    wget --no-check-certificate https://github.com/xichiou/lamp-xoops/archive/master.zip -O lamp-xoops.zip
    unzip -o lamp-xoops.zip
    cd lamp-xoops-master/
    chmod +x *.sh
    clear;

### 2. 安裝 LAMP 網頁伺服器

    ./lamp.sh

### 3. 安裝 XOOPS 架站軟體

    ./xoops.sh

### 註：步驟 2 安裝 LAMP 網頁伺服器過程中，為了可以同步資料庫到 Google 雲端，你需要開啟 Google 帳號做認證

![grive -a](https://github.com/xichiou/lamp-xoops/blob/master/images/grive-a.png)

    登入 Gmail，驗證 Grive，取得授權碼，再貼回上圖

![允許](https://github.com/xichiou/lamp-xoops/blob/master/images/grive_auth.png)
![取得授權碼](https://github.com/xichiou/lamp-xoops/blob/master/images/grive_auth-2.png)

## 其他腳本介紹
### A. 切換 PHP 版本

    ./change_php.php

### B. 關閉網路芳鄰分享功能

    ./disable_samba.sh

### C. 啟用網路芳鄰分享功能

    ./enable_samba.sh

### D. 沒安裝過 網路芳鄰分享功能，現在想要安裝

    ./install_samba.sh

### E. 沒安裝過 Google雲端備份資料的功能，現在想要安裝

    ./install_grive.sh





