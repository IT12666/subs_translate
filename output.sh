#!/bin/bash

currdir=$(dirname "$0")
setup=$currdir/_ESSENTIAL/Setup.txt
if [ "$(grep -F "Sys.updated=" $setup | cut -d "=" -f2)" == "1" ]; then echo "Latest Version"
else curl -L -o $currdir/update.sh https://github.com/IT12666/subs_translate/releases/download/0.0.0/update.sh $currdir 
chmod +x $currdir/update.sh && exec $currdir/update.sh && echo "Updating" && exec $currdir/update.sh 
echo rm -f $currdir/update.sh
fi 

dep_check() { if ! command -v $1 > /dev/null; then echo $1 is missing
read -t 4 -n 1 -p "do you want to install $1? [Y]/N : " install
: "${install:=Y}" && echo -e "\n" && if [ "$install" == "Y" ]; then echo "Installing $1" && eval $2; else echo "Dependency: $1, exiting" && exit 0 ; fi; fi }

dep_check 'brew' '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
dep_check 'opencc' 'brew install opencc'
dep_check 'ffmpeg' 'brew install ffmpeg'
echo "dependency checked"


rm -f $currdir/_ESSENTIAL/log.txt
for dirsub in $(echo $currdir/*/) ; do
if [ -d $dirsub"/LATEST" ] 
then
#loop start

echo -e "\n"
echo -e "\n"
echo -e "\n"
epname=$(basename "$dirsub")
echo "Now Processing --- $epname"

setup=$(dirname $dirsub)"/_ESSENTIAL/Setup.txt"
rm -f $dirsub/LATEST/Translated.ass 
rm -f $dirsub/LATEST/Final.mp4
echo "dir setup complete"

for f in `find $dirsub/LATEST`; do mv -v "$f" "`echo $f | tr '[A-Z]' '[a-z]'`" ; done
mv $dirsub/latest $dirsub/LATEST 2>/dev/null
mv $dirsub/LATEST/test.* $dirsub/LATEST/test.txt 2>/dev/null
mv $dirsub/LATEST/*.ass $dirsub/LATEST/Source.ass 2>/dev/null
mv $dirsub/LATEST/*.mp4 $dirsub/LATEST/Source.mp4 2>/dev/null
cp $dirsub/LATEST/Source.ass $dirsub/LATEST/Translated.ass 2>/dev/null
echo "files preparation completed"

if [ ! -f $dirsub/LATEST/Source.ass ] || [ ! -f $dirsub/LATEST/Source.mp4 ] ; then echo "Error: no file found" && continue; fi
if grep -q "$(grep -F $epname".keywords=" $setup | cut -d "=" -f2)" $dirsub/LATEST/Source.ass; then echo "dir checking complete"; else rm -f $dirsub/LATEST/Translated.ass && echo "Error: no keyword found" && continue; fi

while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed -i '' "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < $(dirname $dirsub)"/_ESSENTIAL/Replacement/"$(basename $dirsub)"/Font.txt"
echo "translated font"


filech=$(grep -F "Video File: " $dirsub/LATEST/Translated.ass | sed 's/Video File: //g')
sed -i '' "s!$filech!Source.mp4!"  $dirsub/LATEST/Translated.ass
echo "changed Aegisub dir"

while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed -i '' "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < $(dirname $dirsub)"/_ESSENTIAL/Replacement/"$(basename $dirsub)"/Style.txt"
echo "style transformed"

opencc -i $dirsub/LATEST/Translated.ass -o $dirsub/LATEST/Translated.ass
echo "translated text"

title=$(grep -F "標題" $dirsub/LATEST/Translated.ass | grep -F "Dialogue" | awk '!/bord0/' | sed 's/.*,,0,0,0,,//' | rev | cut -d ')' -f1 | cut -d '}' -f1 | rev | sort | uniq | paste -sd '|' - | tr -dc '[:print:]'| sed 's/ //g' | sed 's/|/ + /g' | sed 's/櫻桃小丸子 + //g' | cut -f1-2 -d"+")
echo "title grabbed ($title)"

while read line; do source=$(echo $line | rev | cut -d'|' -f 2 | rev) && result=$(echo $line | cut -d'|' -f 2) && sed -i '' "s!$source!$result!g"  $dirsub/LATEST/Translated.ass; done < $(dirname $dirsub)"/_ESSENTIAL/Replacement/Typo.txt"
echo "translate text fixed"

if [ ! -f $dirsub/LATEST/test.txt ]; then mv $dirsub/LATEST/ "$dirsub/"$((1+$(ls $dirsub | sort -nr | head -n1 | grep -Eo '[0-9]{1,5}'))) && mkdir $dirsub/LATEST && dirsub=$dirsub/$(ls $dirsub | sort -nr | head -n1 | grep -Eo '[0-9]{1,5}') && echo "Moved dir to "$(echo $dirsub | grep -o '[^/]*$'); else echo 'Test Mode - NOT moving any files' && dirsub=$dirsub/LATEST; fi

echo "making production"
ffmpeg -i $dirsub/Source.mp4 -vf ass=$dirsub/Translated.ass $dirsub/Final.mp4 -y -loglevel warning
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
echo $setup
sed -i '' '/Sys.updated/d' $setup
read -n 1 -s -r -p 'done'
exit 0



#echo 'export subs_op=' >> ~/.bash_profile
#awk '{print;print;}' /Users/ansoncheng/subs/YY_Doraemon/LATEST/Untitled.ass > /Users/ansoncheng/subs/YY_Doraemon/LATEST/Untitled1.ass  
#cat /Users/ansoncheng/subs/YY_Doraemon/LATEST/Untitled1.ass| grep -o '^.*,' |rev |awk 'NR%2{$0="some text "$0}1'|rev > /Users/ansoncheng/subs/YY_Doraemon/LATEST/Untitled2.ass 
#sed -i '' 's!Default,,0,0,0,, txet emos![蓝胖子]对白-ch,,0,0,0,,!'  /Users/ansoncheng/subs/YY_Doraemon/LATEST/Untitled2.ass 
#sed -i '' 's!Default,,0,0,0,,![蓝胖子]对白-JP,,0,0,0,,!'  /Users/ansoncheng/subs/YY_Doraemon/LATEST/Untitled2.ass 