#!/bin/bash

currdir=$(dirname "$0")

if [ ! -d $currdir"/_ESSENTIAL" ] || [ ! -f $currdir/output.command ]; then
echo "initializing files"
if [ ! -z "$(ls $currdir | grep -v $(basename $0))" ]; then mkdir $currdir"/subs" && mv "$0" $currdir"/subs/"$(basename $0) 2>/dev/null && exec $currdir"/subs/"$(basename $0); fi
rm -f $currdir/gitclone 2>/dev/null
curl https://github.com/IT12666/subs_translate/archive/refs/heads/scripts.zip
mv $currdir/gitclone/.* $currdir/ 2>/dev/null
mv $currdir/gitclone/* $currdir/ 2>/dev/null
rm -rf $currdir/gitclone 2>/dev/null
echo cloned setup files

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
