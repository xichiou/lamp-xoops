<?php
/*------------------ 檔頭（引入檔案） ------------------*/
//一定要引入的XOOPS網站設定檔（必要），否則模組不會運作。
include_once "../../mainfile.php";

//引入XOOPS前台檔案檔頭（必要）
include_once XOOPS_ROOT_PATH."/header.php";

$CR=PHP_EOL;
$CR='<BR>';


$str='';

if (function_exists('posix_getpwuid')){
  $fid=posix_getpwuid(fileowner(XOOPS_ROOT_PATH."/mainfile.php"));
  $uid_name=$fid['name'];
}
else
  $uid_name='apache';


if (function_exists('posix_getgrgid')){
  $fid=posix_getgrgid(filegroup(XOOPS_ROOT_PATH."/mainfile.php"));
  $gid_name=$fid['name'];
}
else
  $gid_name='apache';


$str.='目前XOOPS版本:'.XOOPS_VERSION.$CR;
$str.='網站所在的目錄:'.XOOPS_ROOT_PATH.$CR;
$str.='XOOPS_PATH:'.XOOPS_PATH.$CR;
$str.='XOOPS_VAR_PATH:'.XOOPS_VAR_PATH.$CR;
$str.='<BR>';

$str.='-----------------------------------'.$CR;
$str.='0.先備份資料庫與程式'.$CR;
$str.='-----------------------------------'.$CR;
$str.='cd /tmp'.$CR;
$str.='mysqldump '.XOOPS_DB_NAME.' -u root -p | gzip >'.XOOPS_DB_NAME.'_sql.tar'.$CR;
$str.='<BR>';


$str.='-----------------------------------'.$CR;
$str.='1.登入linux執行以下指令'.$CR;
$str.='-----------------------------------'.$CR;
$str.='cd /tmp'.$CR;
$str.='wget "http://120.115.2.90/modules/tad_uploader/index.php?op=dlfile&cfsn=146&cat_sn=16&name=xoopscore25-2.5.9_tw_for_upgrade_20170803.zip" -O xoopscore25-2.5.9_tw_for_upgrade_20170803.zip'.$CR;
$str.='unzip xoopscore25-2.5.9_tw_for_upgrade_20170803.zip'.$CR;
$str.='chown -R '.$uid_name.'.'.$gid_name.' XoopsCore25-2.5.9_for_upgrade'.$CR;
$str.='cd XoopsCore25-2.5.9_for_upgrade'.$CR;
$str.="rm -rf ".XOOPS_ROOT_PATH."/modules/system".$CR;
// $str.='command_cp=`which --skip-alias cp`'.$CR;
$str.='/bin/cp -rf htdocs/* '.XOOPS_ROOT_PATH.$CR;
$str.='/bin/cp -rf xoops_data/* '.XOOPS_VAR_PATH.$CR;
$str.='/bin/cp -rf xoops_lib/* '.XOOPS_PATH.$CR;
$str.='chmod 777 '.XOOPS_ROOT_PATH.'/mainfile.php'.$CR;
$str.='chmod 777 '.XOOPS_VAR_PATH.'/data/secure.php'.$CR;
$str.='<BR>';

$str.='-----------------------------------'.$CR;
$str.='2.完成以上程序後，請開啟以下連結進行更新'.$CR;
$str.='-----------------------------------'.$CR;
$str.='<a href="'.XOOPS_URL.'/upgrade" target=_blank>'.XOOPS_URL.'/upgrade</a>'.$CR;
$str.='<BR>';

$str.='-----------------------------------'.$CR;
$str.='3.登入linux執行以下指令'.$CR;
$str.='-----------------------------------'.$CR;
$str.='chmod 444 '.XOOPS_ROOT_PATH.'/mainfile.php'.$CR;
$str.='chmod 444 '.XOOPS_VAR_PATH.'/data/secure.php'.$CR;
$str.="rm -rf ".XOOPS_ROOT_PATH."/upgrade".$CR;
$str.='<BR>';
$str.='<BR>';
$str.='<BR>';
echo $str;


die();



/*------------------ 檔尾（輸出內容到樣板） ------------------*/
//套用工具列的程式碼到樣板檔（toolbar_bootstrap()來自tadtools函式庫）
// $xoopsTpl->assign( "toolbar" , toolbar_bootstrap($interface_menu)) ;
// 自訂選單
$xoopsTpl->assign( "xi_sport_menu" , xi_sport_menu()) ;
//套用 bootstrap 的引入語法到樣板檔（get_bootstrap()來自tadtools函式庫）
$xoopsTpl->assign( "bootstrap" , get_bootstrap()) ;
//套用 jquery 的引入語法到樣板檔（get_jquery()來自tadtools函式庫）
$xoopsTpl->assign( "jquery" , get_jquery(true)) ;
//將「是否為該模組管理員」的變數傳送到樣板檔（$isAdmin來自header.php檔）
$xoopsTpl->assign( "isAdmin" , $isAdmin) ;

//引入XOOPS前台檔案檔尾（必要）
include_once XOOPS_ROOT_PATH.'/footer.php';
