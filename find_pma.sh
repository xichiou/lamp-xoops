#!/bin/sh

if [ $# -eq 0 ]; then
  find /var/www/html -name pma.php -o -name adminer.php -print -exec sh $0 '{}' \;
  exit 0
fi

str=$1
#echo find: $1
str=${str/adm.php/}
get1=${str/adminer.php/}
#echo result: $get1

cat >>${get1}.htaccess  <<EOF
<Files pma.php>
    AuthName "Prompt"
    AuthType Basic
    AuthUserFile /var/www/.htpasswd
    Require valid-user
    #Order deny,allow
    #Deny from all
    #Allow from 163.23.xxx.xxx
</Files>

<Files adminer.php>
    AuthName "Prompt"
    AuthType Basic
    AuthUserFile /var/www/.htpasswd
    Require valid-user
    #Order deny,allow
    #Deny from all
    #Allow from 163.23.xxx.xxx
</Files>
EOF

echo 寫入${get1}.htaccess
echo ""

