#!/bin/bash
echo 2463

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
if ! command -v $1 > /dev/null; then echo "could not install packages, please make sure you install brew correctly." && exit 0; fi
echo "dependency checked"


rm -f $currdir/_ESSENTIAL/log.txt
for dirsub in $(echo $currdir/*/) ; do
if [ -d $dirsub"/LATEST" ] 
then
#loop start

echo -e "\n"
epname=$(basename "$dirsub")
echo "Now Processing --- $epname"


setup=$(dirname $dirsub)"/_ESSENTIAL/Setup.txt"
rm -f $dirsub/LATEST/Translated.ass 
rm -f $dirsub/LATEST/Final.mp4
echo "dir setup complete"


for f in `find $dirsub/LATEST`; do mv -v "$f" "`echo $f | tr '[A-Z]' '[a-z]'`" ; done 2>/dev/null
mv $dirsub/latest $dirsub/LATEST 2>/dev/null
mv $dirsub/LATEST/test.* $dirsub/LATEST/test.txt 2>/dev/null
mv $dirsub/LATEST/*.ass $dirsub/LATEST/Source.ass 2>/dev/null
mv $dirsub/LATEST/*.mp4 $dirsub/LATEST/Source.mp4 2>/dev/null
cp $dirsub/LATEST/Source.ass $dirsub/LATEST/Translated.ass 2>/dev/null
echo "files preparation completed"


if [ ! -f $dirsub/LATEST/Source.ass ] || [ ! -f $dirsub/LATEST/Source.mp4 ] ; then echo "Error: no file found" && continue; fi
if grep -q "$(grep -F $epname".keywords=" $setup | cut -d "=" -f2)" $dirsub/LATEST/Source.ass; then echo "dir checking complete"; else rm -f $dirsub/LATEST/Translated.ass && echo "Error: no keyword found" && continue; fi

while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < $(dirname $dirsub)"/_ESSENTIAL/Replacement/"$(basename $dirsub)"/Font.txt"
echo "translated font"




filech=$(grep -F "Video File: " $dirsub/LATEST/Translated.ass | sed $SEDOPTION_L 's/Video File: //g')
sed $SEDOPTION "s!$filech!Source.mp4!"  $dirsub/LATEST/Translated.ass
echo "changed Aegisub dir"


while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < $(dirname $dirsub)"/_ESSENTIAL/Replacement/"$(basename $dirsub)"/Style.txt"
echo "style transformed"

opencc -i $dirsub/LATEST/Translated.ass -o $dirsub/LATEST/Translated.ass
echo "translated text"


title=$(grep -F "標題" $dirsub/LATEST/Translated.ass | grep -F "Dialogue" | awk '!/bord0/' | sed $SEDOPTION_L 's/.*,,0,0,0,,//' | rev | cut -d '}' -f1 | rev | uniq | grep -v '櫻桃小丸子' | sed $SEDOPTION_L 's/ //g' | sed $SEDOPTION_L 's/|/ + /g' | head -n -2)
echo "$title" > $dirsub/LATEST/tmp.txt

while read line; do echo $line; done < $dirsub/LATEST/tmp.txt
echo "translate text fixed"




title=$(cat $dirsub/LATEST/tmp.txt)
#rm -f $dirsub/LATEST/tmp.txt
echo "title grabbed ($title)"

echo -e "\n" && echo -e "\n" && echo -e "\n" && echo -e "\n" && echo -e "\n" && echo -e "\n" && echo -e "\n" && echo -e "\n" && echo -e "\n"





# | cut -f1-2 -d"+")


exit 0 











while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed $SEDOPTION "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < $(dirname $dirsub)"/_ESSENTIAL/Replacement/Typo.txt"
echo "translate text fixed"


if [ ! -f $dirsub/LATEST/test.txt ]; then mv $dirsub/LATEST/ "$dirsub/"$((1+$(ls $dirsub | sort -nr | head -n1 | grep -Eo '[0-9]{1,5}'))) && mkdir $dirsub/LATEST && dirsub=$dirsub/$(ls $dirsub | sort -nr | head -n1 | grep -Eo '[0-9]{1,5}') && echo "Moved dir to "$(echo $dirsub | grep -o '[^/]*$'); else echo 'Test Mode - NOT moving any files' && dirsub=$dirsub/LATEST; fi

echo "making production"
ffmpeg -i $dirsub/Source.mp4 -vf ass=$dirsub/Translated.ass:fontsdir="$currdir/_ESSENTIAL/TRAD_FONT/" $dirsub/Final.mp4 -y -loglevel warning
echo "output complete"


title=$(echo $dirsub | grep -o '[^/]*$')"【"$title"】"
echo "title complete"



echo -e "\n"
echo $(grep -F $epname".title=" $setup | cut -d "=" -f2)"$title 日語繁中"
echo -e "\n"
echo -e $(grep -F $epname".desc=" $setup | cut -d "=" -f2)"【版權聲明】\n本視頻僅提供予(1)學習日語的人士 (2)失聰或聽覺有問題的人或身體上或精神上有其他方面殘障的人\n爲確保影片版權符合公平使用原則，(1)爲免影響該作品的潛在市場價值或價值（如電視台購買特輯），本頻道只會連載最多10期影片 (2)本頻道並不會開啓任何盈利功能，若有廣告產生，則爲版權持有人開啓\n若版權持有人對本影片有任何申訴，請傳送電郵至binary.in.love.520@gmail.com，本影片會立刻下架。"
echo -e "\n"
echo $(grep -F $epname".pic=" $setup | cut -d "=" -f2)
echo -e "\n"
echo $(grep -F $epname".search=" $setup | cut -d "=" -f2)
echo -e "\n"
echo "https://odysee.com/$/upload"

#back to loop
fi
done | tee $currdir/_ESSENTIAL/log.txt
echo -e "\n"
read -t 10 -n 1 -s -r -p 'done'
exit 0

