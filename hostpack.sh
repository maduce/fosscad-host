#!/bin/sh
# hostpack.sh - main 

source ./config.cfg 
source ./lib/megapackzip.sh
source ./lib/dbfunction.sh
source ./lib/echoc.sh


function derp() {

local RETVAL=0

case "$1" in
   --list|-l)
      echo "****Generating parts list $partlist"
      # initial parts list
      list_parts $gitdirectory $partcategories $partlist
      ;;
   --zippack|-z)
      echo "****Generating zip files in $gitziprepo"
      # make and store zipfiles
      zipfromlist $partlist $gitziprepo $gitdirectory
      ;;
   --createdb|-c)
      echo "****Creating $partsdb database."
      echo "**** Populateing $partsdb database."
      # Create database.
      createdb $partsdb
      # Populate datebase
      populatedb $partsdb $partlist $gitziprepo $gitdirectory
      ;;
   --generate|-g)
      echoc yellow "deleting old files"
      rm -rf $partsdb $partlist $partcategories
      sudo su - $webuser -c "rm -rf $gitziprepo"
      echo "generating DB and Zips"
      # create and populate database.
      echo "****Generating parts list $partlist"
      # initial parts list
      list_parts $gitdirectory $partcategories $partlist
      echo "****Generating zip files in $gitziprepo"
      # make and store zipfiles
      sleep 3
      zipfromlist $partlist $gitziprepo $gitdirectory
      echo "****Creating $partsdb database."
      # Create database.
      createdb $partsdb
      echo "**** Populateing $partsdb database."
      # Populate datebase
      populatedb $partsdb $partlist $gitziprepo $gitdirectory
      ;;
      --delete|-d)
      echoc redl "DELETE DATABASE AND STARTING FROM SCRATCH!!"
      rm -rf $partsdb $partlist $gitziprepo $partcategories
      sudo su - $webuser -c "rm -rf $gitziprepo"
      ;;
   --update|-u)
      echoc grayl "*Checking for updates."
      #update Ddatabase and repo
      updatedb $gitdirectory $partcategories $partlist $gitziprepo $partsdb #parts repolocation currentstamp ziplocation laststamp
      ;;
   *)
      echoc yellow "* Usages:"
      echoc yellow "** $0 options are: --generate (-g) --update (-u) and --delete (-d)"
      RETVAL=1
esac;

exit $RETVAL

}

derp $1
