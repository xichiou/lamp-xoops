#!/bin/sh
# this script changes big5 chinese file/directory name to utf8 file/directory name.
# It will recursive.
# it can handle the file name containing space.
# when you use this script, please change to the directory that you want to transfer files' name.
# then execute like "/usr/bin/ic2.sh"
# i hope this script will not impact anything that will crash your system.
# this script works fine for me.

DIR="."

for I in *.htm *.html ; do
    echo "check... $I"
    f=`iconv -f big5 -t utf8 $I > /dev/null 2>&1`
    if [ $? = 0 ]; then
        if  [ "$I" != "$f" ];then
            sed -i 's/charset=big5/charset=utf-8/i'  $I
            iconv -f big5 -t utf8 -o "$I.new" "$I" &&
            mv -f "$I.new" "$I"
            #cp -rv "$I" ~/cbackup/
            # mv -v "$I" "$f"
        else
            echo "skip $I"
        fi
    else
        echo "skip $I"
    fi
done
echo "ok!"

#following from cynosure
for J in * ; do
    if [ -d "$J" ]
    then
        path=`pwd`
        echo "dir ""$J" #where am i
        echo cd  "$path""/""$J"
        cd  "$path""/""$J"
        /usr/bin/ic2.sh
        cd "$path"
    fi
done
#ls *
exit 1;
