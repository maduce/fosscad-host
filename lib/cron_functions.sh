#!/bin/sh
# cron_functions.sh - function used with cron.sh so that there 
#                     is no sudo and to fix permissions.
#


# To unfuck the permissions caused by updating as root in cron.
# used in cron_updatedb
function fix_permissions() {
local user1=$1
local location1=$2

echo "...Giving $user1 ownership of $location1"
chown $user1:$user1 -R $location1


}

##############################################
### function using sudo from megapackzip.sh ##
##############################################

#input $partslist output $zipfoldername. MUST use full paths.
function cron_zipfromlist() {

local ziplist=$1;
local zipfolder=$2;
local topfolder=$3;

# create zipfolder
mkdir -p $zipfolder

for line in $(cat $ziplist);
   do 
      local ziptarget=$(basename $line);
      local pathtopart=$(dirname $line);
      local partcategory=$(echo ${pathtopart#$topfolder/});
      local targetpath=$(echo $zipfolder/$partcategory);
      mkdir -p $targetpath
      #clear
      echoc bluel "....Zipping $ziptarget"
      echo " from: $pathtopart"
      echo " to:   $targetpath"
      pushd $pathtopart > /dev/null 2>&1
      zip -r $targetpath/$ziptarget.zip $pathtopart/$ziptarget > /dev/null 2>&1
      popd > /dev/null 2>&1
   done
}

# if category is deleted this will detect it and delete the corresponding zipfolder of said category 
function cron_category_deletions() {

local oldcategorylist=$1
local newcategorylist=$2
local zipfolder=$3

local deletions=$(echo .tmp01$RANDOM)

textfile_complement $oldcategorylist $newcategorylist > $deletions
# Delete old category folders if $deletion is not empty
if [ -z "$(diff $newcategorylist $oldcategorylist)" ]; then
   echoc greenl "+No category changes detected."
else
   if [ -s "$deletions" ]; then
      echoc yellow "*Category changes detected."
      delete_blanks $deletions
      for line in $(cat $deletions);
      do
         echoc yellow "** Deleting $zipfolder/$line"
         rm -rf $zipfolder/$line
      done
   else
      echoc greenl "+Categories have been updated :)"
   fi
fi

rm  $deletions

}

###############################################
###### function using sudo for dbfunction.sh ##
###############################################

function cron_delete_list() {

delete_blanks $1

if [[ -s $1 ]] ; then

   for line in $(cat $1);
      do
         rm $line
      done
fi ;

}

function cron_updatedb() {
local scriptfolder=$1
local repo=$2
local categorys=$3
local partslist=$4
local zipfolder=$5

local db=$6
local parts_tablename=$(echo parts)
local repolocation_rowname=$(echo repolocation)
local currentstamp_rowname=$(echo currentstamp)
local laststamp_rowname=$(echo laststamp)

local oldcategorys=$(echo .oldcategorylist.txt)
local newlist=$(echo .newlist.txt)
local deletelist=$(echo .deletelist.txt)
local addlist=$(echo .addlist.txt)
local updatelist=$(echo .updatelist.txt)

local updaterowids=$(echo .updaterowids.txt)
local deleterowids=$(echo .deleterowids.txt)
local deleteziplist=$(echo .deleteziplist.txt)
local upgradelist=$(echo .upgradelist.txt)
local upgraderowids=$(echo .upgraderowids.txt)


# git pull 
echo "....checking updates with git pull."
pushd $repo > /dev/null 2>&1;
git pull
popd > /dev/null 2>&1;

echoc grayl "* Current database: $(basename $db)"

cat $categorys > $oldcategorys #backup old $categorys 
list_parts $repo $categorys $newlist
textfile_complement $newlist $partslist > $addlist
delete_blanks $addlist
textfile_complement $partslist $newlist > $deletelist
delete_blanks $deletelist
textfile_complement $partslist $deletelist > $updatelist
delete_blanks $updatelist
getrowid_fromlist $db $deletelist $parts_tablename $repolocation_rowname > $deleterowids
delete_blanks $deleterowids
getziploc_from_rowids $db $deleterowids $parts_tablename $ziplocation_rowname > $deleteziplist
delete_blanks $deleteziplist

echo "....checking for new parts."
cat $addlist
echo "....checking for deleted parts."
cat $deletelist
getrowid_fromlist $db $updatelist $parts_tablename $repolocation_rowname > $updaterowids
delete_blanks $updaterowids
echo "....updating timestamps"
updatestamps_rowids $db $updaterowids $parts_tablename $currentstamp_rowname $repolocation_rowname
echoc grayl "* Checking database for unequal timestamps"
sqlite3 $db "select $repolocation_rowname from $parts_tablename where $currentstamp_rowname != $laststamp_rowname;" > $upgradelist
delete_blanks $upgradelist

# check for changes
echo "...checking for added or changed files"
if [ -z "$(diff $newlist $partslist)" ]; then
   if [ -s "$upgradelist" ]
   then
      echoc yellow "changes detected."
   else
      fix_permissions $gituser $scriptfolder
      fix_permissions $gituser $db
      fix_permissions $gituser $repo
      fix_permissions $gituser $partslist
      fix_permissions $gituser $categorys
      fix_permissions $webuser $zipfolder
      echoc greenl "** $(date) Database is up to date \8D/!"
      rm -f $newlist $addlist $deletelist $deleterowids $deleteziplist $updaterowids $upgradelist $updatelist $oldcategorys
      exit
   fi
fi ;

echo "....getting upgrades if any."
getrowid_fromlist $db $upgradelist $parts_tablename $repolocation_rowname > $upgraderowids
delete_blanks $upgraderowids
echo "....syncing timestamps."
syncstamps_rowids $db $upgraderowids $parts_tablename $currentstamp_rowname $laststamp_rowname
getziploc_from_rowids $db $upgraderowids $parts_tablename $ziplocation_rowname >> $deleteziplist
delete_blanks $deleteziplist
echo "....deleting old zips."
delete_list $deleteziplist
#echo
#cat $updaterowids
echo "...checking for list of upgrades."
cat $upgradelist
#echo "upgraderowids"
#cat $upgraderowids
echo "....deleting old zips."
cat $deleteziplist
echo

echo "....rezipping upgraded parts."
cron_zipfromlist $upgradelist $zipfolder $repo
echo "....deleting old database records."
delete_rowid $db $deleterowids $parts_tablename
echo "....adding new parts to database."
populatedb $db $addlist $zipfolder $repo
echo "....zipping new parts."
cron_zipfromlist $addlist $zipfolder $repo
mv $newlist $partslist

#check for deleted categories and delete trash
cron_category_deletions $oldcategorys $categorys $zipfolder
rm $addlist $deletelist $deleterowids $deleteziplist $updaterowids $upgradelist $upgraderowids $oldcategorys
      fix_permissions $gituser $scriptfolder
      fix_permissions $gituser $db
      fix_permissions $gituser $repo
      fix_permissions $gituser $partslist
      fix_permissions $gituser $categorys
      fix_permissions $webuser $zipfolder
      echoc greenl "** $(date) Database has been updated :D!"

}

####test
#cron_updatedb $megapackzipfolder $gitdirectory $partcategories $partlist $gitziprepo $partsdb
