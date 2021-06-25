#!/bin/bash

currdir=$(dirname "$0")

if [ ! -d $dirsub"/_ESSENTIAL" ] || [ ! -f $dirsub/output.command ]; then
echo "initializing files"
if [ ! -z "$(ls $currdir | grep -v $(basename $0))" ]; then mkdir $currdir"/subs" && mv "$0" $currdir"/subs/"$(basename $0) 2>/dev/null && exec $currdir"/subs/"$(basename $0); fi
rm -f $currdir/gitclone
git clone https://github.com/IT12666/subs_translate.git $currdir/gitclone
mv $currdir/gitclone/.* $currdir/
mv $currdir/gitclone/* $currdir/
rm -rf $currdir/gitclone
echo cloned setup files
setup=$currdir/_ESSENTIAL/Setup.txt
for epname in $(grep -F "." $setup | cut -d '.' -f1 | sort | uniq ); do mkdir -p $currdir"/"$epname"/"$(grep -F $epname".nextep=" $setup | cut -d "=" -f2); done
echo episode dirertory created

else
echo "checking for update"
echo "git check started"

fi

find $currdir -type f -iname "*.command" -exec chmod u+x {} \;
