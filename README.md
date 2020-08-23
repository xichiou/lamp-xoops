## 這個專案設計的自動化腳本，幫助你把一部剛安裝好 CentOS 7 作業系統的主機，快速的安裝 LAMP 套件成為網頁伺服器，以及安裝 XOOPS 架站軟體，特色如下：

* 安裝過程簡單，只要複製、貼上和輸入資料
* 提供 PHP 5.6、 7.0、 7.1、 7.2 和 7.3 五種版本供你選擇安裝
* 資料庫採用 MariaDB 提供 5.5、10.3、10.4 三種版本供你選擇安裝
* 禁止 root 直接使用 sshd 服務遠端登入主機，提升系統安全
* 每天早上自動更新系統
* 每天早上自動校時
* 使用 Google 雲端硬碟每天備份資料庫和網頁
* 提供網路芳鄰分享資料夾，方便你管理伺服器裡面的檔案

---

## 操作步驟：
### 1. 下載自動化腳本：
#### 使用 Putty 軟體遠端登入伺服器，切換成 root 最高權限，複製以下指令貼到 Putty 視窗內
#### 這個步驟只是下載自動化腳本到你的伺服器，資料夾位置 /root/lamp-xoops-master，對伺服器沒有影響，可以重複執行

    cd /root
    yum install -y unzip wget
    wget --no-check-certificate https://github.com/xichiou/lamp-xoops/archive/master.zip -O lamp-xoops.zip
    unzip -o lamp-xoops.zip
    rm -f lamp-xoops.zip
    cd lamp-xoops-master/
    chmod +x *.sh
    clear;


### 2. 安裝 LAMP 套件成為網頁伺服器 
#### 這個步驟只適合還沒安裝Apache+MySQL+PHP，因此這個步驟最多只要執行一次

    ./lamp.sh

### 3. 安裝 XOOPS 架站軟體
#### 這個步驟引導你安裝 XOOPS ，一台伺服器可以安裝多個 XOOPS 網站

    ./xoops.sh

#### 註：步驟 2 安裝 LAMP 套件過程中，為了可以同步資料庫到 Google 雲端，你需要開啟 Google 帳號做認證

![grive -a](https://github.com/xichiou/lamp-xoops/blob/master/images/grive-a.png)

    登入 Gmail，驗證 Grive，取得授權碼，再貼回上圖

![允許](https://github.com/xichiou/lamp-xoops/blob/master/images/grive_auth.png)
![取得授權碼](https://github.com/xichiou/lamp-xoops/blob/master/images/grive_auth-2.png)

---
## 其他腳本介紹
#### 使用以下腳本前先切換到腳本目錄
    
    cd /root/lamp-xoops-master

### A. 切換 PHP 版本

    ./change_php.sh
---
### B. 關閉網路芳鄰分享功能

    ./disable_samba.sh
---
### C. 啟用網路芳鄰分享功能

    ./enable_samba.sh
---
### D. 沒安裝過 網路芳鄰分享功能，現在想要安裝

    ./install_samba.sh
---
### E. 沒安裝過 Google雲端備份資料的功能，現在想要安裝

    ./install_grive.sh
---
### F. 重新下載自動化腳本，作用與前面步驟1相同

    ./update.sh
---
### G. 檢查XOOPS網站運行的版本並且更新
#### 更新XOOPS核心到2.5.9，[模組]站長工具箱到2.81，[模組]tadtools到3.26和BootStrap4升級補丁，這些是近期最重要的更新

    ./upgrade_xoops.sh

#### 或是直接指定你的網站路徑當作參數，例如: /var/www/html/xoops
    ./upgrade_xoops.sh /var/www/html/xoops

---
### H. 顯示您現有的XOOPS網站的各項參數，方便移機用

    ./show_xoops_var.sh

#### 或是直接指定你的網站路徑當作參數，例如: /var/www/html/xoops
    ./show_xoops_var.sh /var/www/html/xoops
#### 如果在舊機器上不想要安裝本專案全部的腳本，可以用下列指令代替
    curl -s https://raw.githubusercontent.com/xichiou/lamp-xoops/master/show_xoops_var.sh | bash -s --

#### 或是直接指定你的網站路徑當作參數，例如: /var/www/html/xoops
    curl -s https://raw.githubusercontent.com/xichiou/lamp-xoops/master/show_xoops_var.sh | bash -s -- /var/www/html/xoops

---
### I. 打包您現有的XOOPS網站的程式、資料庫，做為備份整個網站或是傳輸到遠端新伺服器上

    ./dump_xoops_var.sh
    
#### 直接指定你的網站路徑當作參數，例如: /var/www/html/xoops
    curl -s https://raw.githubusercontent.com/xichiou/lamp-xoops/master/dump_xoops.sh | bash -s -- /var/www/html/xoops
    
---
### J. 還原上一步驟的XOOPS網站的程式、資料庫
#### 指定打包好的檔案的資料夾路徑

    ./restore_xoops.sh 資料夾路徑

---
### K. 顯示主機安裝 Apache、MySQL、PHP 的版本

    ./show_lamp_ver.sh

---
### L. 更新 MySQL(MariaDB) 版本

    ./update_mariadb.sh

