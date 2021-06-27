#!/bin/bash

currdir=$(dirname "$0")
rm -f $currdir/*.zip

download() { 
curl -s -L -o $currdir/$1.zip https://github.com/IT12666/subs_translate/archive/refs/heads/$1.zip $currdir
unzip -qq -o $currdir"/"$1".zip" -d $currdir"/" 
rm -f $currdir/$1.zip 
mv $currdir"/subs_translate-"$1 $currdir"/"$1;}

scriptup() { 
rm -rf $currdir/Replacement
rm -rf $currdir/_ESSENTIAL/Replacement
mv $currdir/scripts/.* $currdir/ 
mv $currdir/scripts/* $currdir/ && rm -rf $currdir/scripts 
mv $currdir/Replacement $currdir/_ESSENTIAL/Replacement 
mv $currdir/Setup.txt $currdir/_ESSENTIAL/Setup.txt 
echo preference and script updated;}

if [ ! -d $currdir"/_ESSENTIAL" ] || [ ! -f $currdir/output.sh ]; then
echo "initializing files"


if [ ! -z "$(ls $currdir | grep -v $(basename $0) | grep -v "output.sh")" ]; then mkdir $currdir"/subs" && mv "$0" $currdir"/subs/"$(basename $0) 2>/dev/null && echo "Directory is not empty, creating directory" && exec $currdir"/subs/"$(basename $0); fi
rm -f $currdir/*/ 2>/dev/null
download '_ESSENTIAL' 2>/dev/null
download 'scripts' 2>/dev/null
echo fetched from server

scriptup 2>/dev/null

setup=$currdir/_ESSENTIAL/Setup.txt
for epname in $(grep -F "." $setup | cut -d '.' -f1 | sort | uniq ); do mkdir -p $currdir"/"$epname"/LATEST" && mkdir $currdir"/"$epname"/"$(grep -F $epname".nextep=" $setup | cut -d "=" -f2); done
echo episode dirertory created

find $currdir -type f -iname "*.sh" -exec chmod u+x {} \;
rm -f $0
echo "setup complete, Please run output.sh"

else
download 'scripts' 2>/dev/null
echo fetched from server
scriptup 2>/dev/null

fi

find $currdir -type f -iname "*.sh" -exec chmod u+x {} \;
rm -f $0
exec $currdir/output.sh
