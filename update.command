#!/bin/bash

currdir=$(dirname "$0")
rm -f $currdir/*.zip

download() { curl -L -o $currdir/$1.zip https://github.com/IT12666/subs_translate/archive/refs/heads/$1.zip $currdir
unzip -o -qq $currdir"/"$1".zip" -d $currdir"/" && rm -f $currdir/$1.zip && mv $currdir"/subs_translate-"$1 $currdir"/"$1;}

if [ ! -d $currdir"/_ESSENTIAL" ] || [ ! -f $currdir/output.command ]; then
echo "initializing files"
if [ ! -z "$(ls $currdir | grep -v $(basename $0))" ]; then mkdir $currdir"/subs" && mv "$0" $currdir"/subs/"$(basename $0) 2>/dev/null && echo "Directory is not empty, creating directory" && exec $currdir"/subs/"$(basename $0); fi
rm -f $currdir/*/ 2>/dev/null


#download '_ESSENTIAL' 2>/dev/null
download 'scripts'
read


mv $currdir/scripts/.* $currdir/ 2>/dev/null
mv $currdir/scripts/* $currdir/ 2>/dev/null

echo fetched from server

read 

mv $currdir/Replacement $currdir/_ESSENTIAL/Replacement
mv $currdir/Setup.txt $currdir/_ESSENTIAL/Setup.txt
echo dirertory prepared

setup=$currdir/_ESSENTIAL/Setup.txt
for epname in $(grep -F "." $setup | cut -d '.' -f1 | sort | uniq ); do mkdir -p $currdir"/"$epname"/LATEST" && mkdir $currdir"/"$epname"/"$(grep -F $epname".nextep=" $setup | cut -d "=" -f2); done
echo episode dirertory created

else
echo "checking for update"
echo "git check started"
read -p 'update'

fi

find $currdir -type f -iname "*.command" -exec chmod u+x {} \;
exec $currdir/output.command