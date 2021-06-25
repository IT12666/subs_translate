!/bin/bash

currdir=$(dirname "$0")


if [ ! -d $dirsub"/_ESSENTIAL" ] || [ ! -f $dirsub/output.command ]; then
echo "initializing files"
rm -f $currdir/gitclone
git clone https://github.com/IT12666/subs_translate.git $currdir/gitclone
mv $currdir/gitclone/.* $currdir/
mv $currdir/gitclone/* $currdir/
rm -f $currdir/gitclone
echo cloned setup files
setup=$currdir/_ESSENTIAL/Setup.txt
for epname in $(grep -F "." $setup | cut -d '.' -f1 | sort | uniq ); do mkdir -p $currdir"/"$epname"/"$(grep -F $epname".nextep=" $setup | cut -d "=" -f2); done
echo episode dirertory created

else
echo "checking for update"
echo "git check started"

fi

