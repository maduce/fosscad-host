#!/bin/sh
# dbfunctions.sh - used to load the sqlite database
#

#source ./config.cfg
#source ./megapackzip.sh

function createdb() {
local db=$1
rm $db > /dev/null 2>&1;

## Creating parts table
# folder name of part
# part category
# path to part folder 
# path to zip of part folder
# current time stamp of last change to parts folder
# last time stamp of last change to parts folder
sqlite3 $db "CREATE TABLE parts(name TEXT UNIQUE, category TEXT, repolocation TEXT UNIQUE, ziplocation TEXT, currentstamp TEXT, laststamp TEXT);"

}

# populate the db for the first time.
function populatedb() {

local db=$1
local partslist=$2
local zipfolder=$3
local topfolder=$4

delete_blanks $partslist

if [[ -s $partslist ]] ; then

   for line in $(cat $partslist);
       do 
          local partname=$(basename $line)
          local pathtopart=$(dirname $line)
          local partcategory=$(echo ${pathtopart#$topfolder/})
          local repolocation=$(echo $line);
          local ziplocation=$(echo $zipfolder/$partcategory/$partname.zip)
          local currentstamp=$(check_date $repolocation)
          local laststamp=$(check_date $repolocation)
          clear
          echo 
          echo "....$(tput setaf 2)inserting $partname in $(basename $db)$(tput sgr0)"
          echo -e "$partname|$partcategory\n$repolocation\n$ziplocation\n$currentstamp\n$laststamp"
          sqlite3 $db "insert into parts(name,category,repolocation,ziplocation,currentstamp,laststamp) values ('$partname','$partcategory','$repolocation','$ziplocation','$currentstamp','$laststamp');"
       done
    echo "....$(tput setaf 2)$(basename $db) has been populated.$(tput sgr0)"
    echo 
fi ;

}

# Return timestamp of folder $1 
check_date() {
local targetfolder=$1
local current_date=$(date +%s -r $targetfolder/)
echo $current_date
}

#compare current timestamp of folder $1 with $2
compare_date () {
local targetfolder=$1
local last_date=$2
local current_date=$(check_date $targetfolder)

#echo "current_date=$current_date"
if [[ $current_date != $last_date ]]; then 
   echo 1; 
else
   echo 0;
fi
}

# Sync laststamp with currentstamp in db.
function syncstamps_rowids() {

local db=$1
local synclist=$2
local parts_tablename=$3
local currentstamp_rowname=$4
local laststamp_rowname=$5

if [[ -s $synclist ]] ; then

   for line in $(cat $synclist);
      do
         #echo "select $currentstamp_rowname from $parts_tablename where rowid=$line"
         local currentstamp=$(sqlite3 $db "select $currentstamp_rowname from $parts_tablename where rowid=$line;")
         echoc greenl "update $parts_tablename set $laststamp_rowname equal to $currentstamp where rowid $line"
         sqlite3 $db "UPDATE $parts_tablename SET $laststamp_rowname='$currentstamp' WHERE rowid=$line;"
      done
fi ;
}


# Some set theory
function textfile_union() {
local A=$1
local B=$2

#output union 
cat $A $B |sort -u |sed '/^$/d'
}

function textfile_complement() {
local A=$1
local B=$2

# if B isnt empty, return A-B, else so cat A
if [ -s "$B" ]
then
   # output A complement B
   awk 'NR == FNR { list[tolower($0)]=1; next } { if (! list[tolower($0)]) print }' $B $A |sed '/^$/d'
else
   cat $A
   fi
}

function textfile_intersection() {
# A^B=(AuB)-(A-B)-(b-A)
local A=$1
local B=$2
local union1=$(echo .tmp03_$RANDOM)
local union2=$(echo .tmp04_$RANDOM)
local com1=$(echo .tmp05_$RANDOM)
local com2=$(echo .tmp06_$RANDOM)

textfile_union $A $B > $union1
textfile_complement $A $B > $com1
textfile_complement $B $A > $com2
textfile_union $com1 $com2 > $union2
rm $com1 $com2
#intersection
textfile_complement $union1 $union2
rm $union1 $union2 
}

#removes empty lines from file
function delete_blanks() {
local tmp01=$(echo .tmp01$RANDOM)

sed '/^$/d' $1 > $tmp01;

mv $tmp01 $1

}

# Returns list of rowids given list of items in rowname of tablename in db.
function getrowid_fromlist() {
local db=$1
local fromlist=$2
local tablename="$3"
local rowname="$4"

if [[ -s $fromlist ]] ; then

   for line in $(cat $fromlist);
      do
         sqlite3 $db "select rowid from $tablename where $rowname='$line';"
      done

fi ;

}

# Update current timestamps in db give a list of rowids
function updatestamps_rowids() {

local db=$1
local rowidlist=$2
local parts_tablename="$3"
local currentstamp_rowname="$4"
local repolocation_rowname="$5"

if [[ -s $rowidlist ]] ; then

   for line in $(cat $rowidlist);
      do
         local newstamp=$(date +%s -r $(echo $(sqlite3 $db "select $repolocation_rowname from $parts_tablename where rowid=$line;")))
         #echo $newstamp
         sqlite3 $db "update $parts_tablename set $currentstamp_rowname=$newstamp where rowid=$line;"
      done

fi ;

}

# returns list of zipfile locations stored in db from a given list of rowids
function getziploc_from_rowids() {

local db=$1
#local rowidlist=$2
#local parts_tablename=$3
#local ziplocation_rowname=$4

delete_blanks $2

if [[ -s $2 ]] ; then

   for line in $(cat $2);
      do
         sqlite3 $db "select ziplocation from parts where rowid=$line;"
      done
fi ;

}       


function delete_list() {

delete_blanks $1

if [[ -s $1 ]] ; then

   for line in $(cat $1);
      do
         rm $line;
      done
fi ;

}

delete_rowid() {
local db=$1
local rowidlist=$2
local parts_tablename="$3"

delete_blanks $rowidlist
if [[ -s $rowidlist ]] ; then

   for line in $(cat $rowidlist);
      do
      #echoc greenl "....Deleting row $line from $parts_tablename in $db."
      sqlite3 $db "DELETE FROM $parts_tablename WHERE rowid=$line"
      done
fi ;

}

# Where the magic happens
function updatedb() {
repo=$1
categorys=$2
partslist=$3
zipfolder=$4

db=$5
parts_tablename=$(echo parts)
repolocation_rowname=$(echo repolocation)
currentstamp_rowname=$(echo currentstamp)
laststamp_rowname=$(echo laststamp)

newlist=$(echo .newlist.txt)
deletelist=$(echo .deletelist.txt)
addlist=$(echo .addlist.txt)
updatelist=$(echo .updatelist.txt)


updaterowids=$(echo .updaterowids.txt)
deleterowids=$(echo .deleterowids.txt)
deleteziplist=$(echo .deleteziplist.txt)
upgradelist=$(echo .upgradelist.txt)
upgraderowids=$(echo .upgraderowids.txt)


# git pull 
echo "....checking updates with git pull."
pushd $repo > /dev/null 2>&1;
git pull
popd > /dev/null 2>&1;


# MegapackZip.sh
#list_parts $repo $categorys $partslist
#zipfromlist $partslist $zipfolder $repo

# dbfunctions.sh
echoc grayl "* Current database: $(basename $db)"
#createdb $db
#populatedb $db $partslist $zipfolder $repo

#function derp {
# update_functions
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
#echo
#cat $newlist
#sleep 5
echo "....checking for new parts."
cat $addlist
echo "....checking for deleted parts."
cat $deletelist
#echo "updatelist"
#cat $updatelist
#echo "deletrowids"
#cat $deleterowids
#echo "deleteziplist"
#cat $deleteziplist
#echo "getting update rowids"
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
      echoc greenl "** Database is up to date \8D/!"
      rm -f $newlist $addlist $deletelist $deleterowids $deleteziplist $updaterowids $upgradelist $updatelist
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
zipfromlist $upgradelist $zipfolder $repo
echo "....deleting old database records."
delete_rowid $db $deleterowids $parts_tablename
echo "....adding new parts to database."
populatedb $db $addlist $zipfolder $repo
echo "....zipping new parts."
zipfromlist $addlist $zipfolder $repo
mv $newlist $partslist

rm $addlist $deletelist $deleterowids $deleteziplist $updaterowids $upgradelist $upgraderowids 

}

####test
#updatedb $gitdirectory $partcategories $partlist $gitziprepo $partsdb #parts repolocation currentstamp ziplocation laststamp
#createdb $partsdb
#populatedb $partsdb $partlist $gitziprepo $gitdirectory
#check_date $gitziprepo
#compare_date $gitziprepo 1374407763

