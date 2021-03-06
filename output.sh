#!/bin/bash

#SYSTEM PRESET
if [[ "$OSTYPE" == "darwin"* ]]; then SEDOPTION="-i ''"; else SEDOPTION="-ri"; fi
if [[ "$OSTYPE" == "darwin"* ]]; then SEDOPTION_L=""; else SEDOPTION_L=""; fi

currdir=$(dirname "$0")
setup=$currdir/_ESSENTIAL/Setup.txt

runupdate() { curl -s -L -o $currdir/update.sh https://raw.githubusercontent.com/IT12666/subs_translate/scripts/update.sh $currdir
chmod +x $currdir/update.sh && exec $currdir/update.sh && echo "Updating" && exec $currdir/update.sh
}

if [ ! -f $setup ]; then runupdate; fi
if [ "$(grep -F "Sys.updated=" $setup | cut -d "=" -f2)" == "1" ]; then echo "Latest Version"; else runupdate; fi 

dep_check() { if ! command -v $1 > /dev/null; then echo $1 is missing
read -t 4 -n 1 -p "do you want to install $1? [Y]/N : " install
: "${install:=Y}" && echo -e "\n" && if [ "$install" == "Y" ]; then echo "Installing $1" && eval $2; else echo "Dependency: $1, exiting" && exit 0 ; fi; fi }

sed $SEDOPTION '/Sys.updated/d' $setup

dep_check 'opencc' 'brew install opencc'
dep_check 'ffmpeg' 'brew install ffmpeg'
#if [ ! command -v opencc > /dev/null ] || [ ! command -v ffmpeg > /dev/null ] ; then echo "could not install packages, please make sure you install brew correctly." && exit 0; fi
echo "dependency checked"

for logfile in $(ls -t1 $currdir/_ESSENTIAL/log/ | tail -n +10 ); do rm -f $currdir/_ESSENTIAL/log/$logfile; done 2>/dev/null
echo "deleted old logs"

for dirsub in $(echo $currdir/*/) ; do
if [ -d $dirsub"/LATEST" ] 
then
#loop start

echo -e "\n"
epname=$(basename "$dirsub")
echo "Now Processing --- $epname"

dirsub=$(readlink -m $dirsub)
echo "fixed URL"

setup=$(dirname $dirsub)"/_ESSENTIAL/Setup.txt"

for f in $dirsub/LATEST/*\ *; do mv "$f" "${f// /}"; done 2>/dev/null
for f in $dirsub/LATEST/*的副本; do mv "$f" "${f//的副本/}"; done 2>/dev/null
for f in $dirsub/LATEST/*; do mv "$dirsub/LATEST/$(basename $f)" "$dirsub/LATEST/$(echo $(basename $f) | tr '[A-Z]' '[a-z]')"; done 2>/dev/null

rm -f $dirsub/LATEST/translated.ass
rm -f $dirsub/LATEST/final.mp4

mv $dirsub/latest $dirsub/LATEST 2>/dev/null
mv $dirsub/LATEST/test.* $dirsub/LATEST/test.txt 2>/dev/null
mv $dirsub/LATEST/*.ass $dirsub/LATEST/Source.ass 2>/dev/null
mv $dirsub/LATEST/*.mp4 $dirsub/LATEST/Source.mp4 2>/dev/null
mv $dirsub/LATEST/*.jpeg $dirsub/LATEST/Cover.jpg 2>/dev/null
mv $dirsub/LATEST/*.jpg $dirsub/LATEST/Cover.jpg 2>/dev/null
cp $dirsub/LATEST/Source.ass $dirsub/LATEST/Translated.ass 2>/dev/null
echo "files preparation completed"


if [ ! -f $dirsub/LATEST/Source.ass ] ; then echo "Error: no file found" && continue; fi
//|| [ ! -f $dirsub/LATEST/Source.mp4 ]
if grep -q "$(grep -F $epname".keywords=" $setup | cut -d "=" -f2)" $dirsub/LATEST/Source.ass; then echo "dir checking complete"; else rm -f $dirsub/LATEST/Translated.ass && echo "Error: no keyword found" && continue; fi

while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < "$currdir/_ESSENTIAL/Replacement/$(basename $dirsub)/Font.txt"
echo "translated font"

if [ ! -f $dirsub/LATEST/Cover.jpg ] ; then echo "No Cover found, Downloading..." && curl -s -L -o $dirsub/LATEST/Cover.jpg $(grep -F $epname".cover=" $setup | cut -d "=" -f2) ; else echo "Uploading Cover" && cover=$(curl -s --upload-file $dirsub/LATEST/Cover.jpg https://transfer.sh/yysub.jpg 2>/dev/null) ; fi
: "${cover:= $(grep -F $epname".cover=" $setup | cut -d "=" -f2)}"
echo "uploaded cover"

filech=$(grep -F "Video File: " $dirsub/LATEST/Translated.ass | sed $SEDOPTION_L 's/Video File: //g') 2>/dev/null
sed $SEDOPTION "s!$filech!Source.mp4!"  $dirsub/LATEST/Translated.ass 2>/dev/null
echo "changed Aegisub dir"

while read line; do source=$(echo "$line" | rev | cut -d'|' -f 2 | rev | sed 's/\([^\\]\)&/\1\\\&/g' | sed 's/[][]/\\&/g') && result=$(echo "$line" | cut -d'|' -f 2 | sed 's/\([^\\]\)&/\1\\\&/g' | sed 's/[][]/\\&/g') && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < "$currdir/_ESSENTIAL/Replacement/$(basename $dirsub)/Style.txt"
echo "style transformed"

while read line; do source=$(echo "$line" | rev | cut -d'|' -f 2 | rev | sed 's/\([^\\]\)&/\1\\\&/g' | sed 's/[][]/\\&/g') && result=$(echo "$line" | cut -d'|' -f 2 | sed 's/\([^\\]\)&/\1\\\&/g' | sed 's/[][]/\\&/g') && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < "$currdir/_ESSENTIAL/Replacement/Typo.txt"
echo "translate text fixed"

opencc -c s2hk -i $dirsub/LATEST/Translated.ass -o $dirsub/LATEST/Translated.ass
echo "translated text"

title=$(grep -F "標題" $dirsub/LATEST/Translated.ass | grep -F "Dialogue" | awk '!/bord0/' | sed $SEDOPTION_L 's/.*,,0,0,0,,//' | rev | cut -d '}' -f1 | rev | uniq | grep -v '櫻桃小丸子' | sed $SEDOPTION_L 's/ //g' | awk 'NF' | tr '\r' ',' | tr '\n' ',' | sed $SEDOPTION_L 's/,,/,/g' | sed $SEDOPTION_L 's/,/ + /g' | cut -f1-2 -d"+" | sed 's/.\{2\}$//' | sed $SEDOPTION_L 's/「//g' | sed $SEDOPTION_L 's/」篇//g' | sed $SEDOPTION_L 's/」//g' )
echo "title grabbed ($title)"

while read line; do source=$(echo "$line" | rev | cut -d'|' -f 2 | rev | sed 's/\([^\\]\)&/\1\\\&/g' | sed 's/[][]/\\&/g') && result=$(echo "$line" | cut -d'|' -f 2 | sed 's/\([^\\]\)&/\1\\\&/g' | sed 's/[][]/\\&/g') && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < "$currdir/_ESSENTIAL/Replacement/Typo.txt"
echo "translate text fixed"

if [ ! -f $dirsub/LATEST/test.txt ]; then mv $dirsub/LATEST/ "$dirsub/"$((1+$(ls $dirsub | sort -nr | head -n1 | grep -Eo '[0-9]{1,5}'))) && mkdir $dirsub/LATEST && dirsub=$dirsub/$(ls $dirsub | sort -nr | head -n1 | grep -Eo '[0-9]{1,5}') && echo "Moved dir to "$(echo $dirsub | grep -o '[^/]*$'); else echo 'Test Mode - NOT moving any files' && dirsub=$dirsub/LATEST; fi

echo "making production"
ffmpeg -i $dirsub/Source.mp4 -vf ass=$dirsub/Translated.ass $dirsub/Final.mp4 -y -stats &> "$currdir/_ESSENTIAL/log/"$(date +'%m-%d-%Y-%T')"_ffmpeg.txt"
echo "output complete"

epno=$(echo $dirsub | grep -o '[^/]*$')
title=$(grep -F $epname".title=" $setup | cut -d "=" -f2)$epno"【"$title"】日語繁中"
desc=$(grep -F $epname".desc=" $setup | cut -d "=" -f2)"【版權聲明】\n本視頻僅提供予(1)學習日語的人士 (2)失聰或聽覺有問題的人或身體上或精神上有其他方面殘障的人\n爲確保影片版權符合公平使用原則，(1)爲免影響該作品的潛在市場價值或價值（如電視台購買特輯），本頻道只會連載最多10期影片 (2)本頻道並不會開啓任何盈利功能，若有廣告產生，則爲版權持有人開啓\n若版權持有人對本影片有任何申訴，請傳送電郵至binary.in.love.520@gmail.com，本影片會立刻下架。"
echo "video info complete"


echo -e "\n"
echo $title
echo -e "\n"
echo -e $desc
echo -e "\n"
echo $cover
echo -e "\n"
echo $(grep -F $epname".search=" $setup | cut -d "=" -f2)
echo -e "\n"
echo "https://www.youtube.com/upload"
echo "https://odysee.com/$/upload"

#echo "downloading script"
#curl -s -L -o $dirsub/odysee.zip https://github.com/lbryio/lbry-sdk/releases/latest/download/lbrynet-linux.zip
#unzip -qq -o $dirsub"/odysee.zip" -d $dirsub"/" 
#mv $dirsub/lbrynet $dirsub/odysee
#echo "downloaded script"

#chmod u+x $dirsub/odysee
#startlbry() { sudo $dirsub/odysee start --api=127.0.0.1:5279 --streaming-server=127.0.0.1:5280 &>/dev/null; }
#touch $dirsub/input.csv
#echo 'title,name,file_path,description,channel_name,claim_address,thumbnail' >> $dirsub/input.csv
#echo "$title,$epno,$dirsub/Final.mp4,$desc,$(grep -F $epname".chaddr=" $setup | cut -d "=" -f2),$(grep -F $epname".chname=" $setup | cut -d "=" -f2),$cover" >> $dirsub/input.csv
#publishlbry() { sudo python3 $currdir/_ESSENTIAL/lbry/upload.py --input=$dirsub/input.csv ; }
#--config=$currdir/_ESSENTIAL/lbry_uploader/config/default.ini ; }
#startlbry & sleep 10 && echo "start" && publishlbry
#$(grep -F $epname".chname=" $setup | cut -d "=" -f2) "" 
 ### change final.mp4 to Final.mp4
#rm -rf $dirsub/odysee.*

#back to loop
fi | tee "$currdir/_ESSENTIAL/log/"$(date +'%m-%d-%Y-%T')"_script.txt"
done
echo -e "\n"
echo 'done'
exit 0

