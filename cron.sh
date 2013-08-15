#!/bin/sh
# cron.sh - a simple script to cron hostlib.sh --update
# Example Every 24 hours: 0 */24 * * * /oath/to/cron.sh
# To do so with logs: 0 */24 * * * /oath/to/cron.sh 2>&1 >> /path/to/logfile.log
#
# Note: Be sure to set megapackzipfolder, gitziprepo,
#       gituser and webuser. DO NOT set users to root
#       but be sure to add this script to roots cron.


#########################################
#### Configuration cron script below ####
#########################################

# git repository git url
#gitrepoaddr=$(echo "git://gitorious.org/fosscad/fosscad-repo.git")
#gitrepoaddr=$(echo "https://github.com/maduce/fosscad-repo.git")

# fosscad-host folder. Should be same as in config.cfg.
# USE EXACT PATH!
megapackzipfolder=$(echo "/path/to/fosscad-host")

#sqlite3 database.
# Should be same as in config.cfg.
partsdb=$(echo "$megapackzipfolder/partsdb.db")

# Local path to git repository folder. 
# Should be same as in config.cfg.
gitdirectory=$(echo "$megapackzipfolder/fosscad-repo")

# Define the location where the zipped files will me stored.
# Should be same as in config.cfg.
gitziprepo=$(echo "/path/to/zippedlib")

# Define git user. This is the user that runs hostlib.sh and
# git clone the repos. DO NOT SET THIS TO "$USER". Use exact
# usename.
gituser=$(echo "SET-THIS-USERNAME")

# Web server user.  
# This is the user that writes to zippedlib and when hosting a website
# is likely the webserver username, i.e., www-data. Set this to whichever
# username was used in config.cfg but do not use $USER, use exact username.
webuser=$(echo "SET-THIS-USERNAME")

# Hidden file used at runtime.
# Should be same as in config.cfg.
partlist=$(echo "$megapackzipfolder/.current_parts_list.lst")

# Predefine category list for Library. Is listed at bottom of README.md
# Should be same as in config.cfg.
partcategories=$(echo "$megapackzipfolder/.part_categories.lst")

######################################################################
#       ** STOP! You do not need to do anything below blow!          #
######################################################################


source $megapackzipfolder/lib/cron_functions.sh
source $megapackzipfolder/lib/megapackzip.sh
source $megapackzipfolder/lib/dbfunction.sh
source $megapackzipfolder/lib/echoc.sh

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo
   echoc redl "*** ERROR! Usage:"
   echoc redl "This script is for cron and must be run as root...." 1>&2
   echoc redl "If you have no idea what that means leave it alone!" 1>&2
   echo
   exit 1
fi

function cronstabator() {

local scriptfolder=$1
local gitrepodir=$2
local categorylist=$3
local partlst=$4
local zipfolder=$5
local db=$6

      #go to the script folder
      echoc grayl "* $(date) Checking for updates."
      pushd $scriptfolder
      #update Ddatabase and repo
      cron_updatedb $scriptfolder $gitrepodir $categorylist $partlst $zipfolder $db
      #echo "updatedb $gitdirectory $partcategories $partlist $gitziprepo $partsdb"
      popd
      
}

cronstabator $megapackzipfolder $gitdirectory $partcategories $partlist $gitziprepo $partsdb
