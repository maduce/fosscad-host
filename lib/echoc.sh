#!/bin/bash
# colorecho.sh - easy color echo script

# lack        0;30     Dark Gray     1;30"
# Blue        0;34     Light Blue    1;34"
# Green       0;32     Light Green   1;32"
# Cyan        0;36     Light Cyan    1;36"
# Red         0;31     Light Red     1;31"
# Purple      0;35     Light Purple  1;35"
# Brown       0;33     Yellow        1;33"
# Light Gray  0;37     White         1;37"

usage_error () {
   echo -e "$1 syntax is $1 <color> \"<phase>\""
   echo ""
   echo "where color is one of the following"
   echo "| lack        | grayd    "
   echo "| Blue        | bluel   "
   echo "| Green       | greenl  "
   echo "| Cyan        | cyanl   "
   echo "| Red         | redl    "
   echo "| Purple      | purplel "
   echo "| Brown       | yellow  "
   echo "| White       | grayl   "
   echo "Note: Quotes around <phrase> are important."
   echo -e "ie) sh $0 red \"hello world\""
   echo ; 
}

function echoc () {

local color=$1
local phrase=$2

local lack=$(echo -e "\e[0;30m$phrase \e[0m")
local blue=$(echo -e "\e[0;34m$phrase \e[0m")
local green=$(echo -e "\e[0;32m$phrase \e[0m")
local cyan=$(echo -e "\e[0;36m$phrase \e[0m")
local red=$(echo -e "\e[0;31m$phrase \e[0m")
local purple=$(echo -e "\e[0;35m$phrase \e[0m")
local brown=$(echo -e "\e[0;33m$phrase \e[0m")
local grayl=$(echo -e "\e[0;37m$phrase \e[0m")
local grayd=$(echo -e "\e[1;30m$phrase \e[0m")
local bluel=$(echo -e "\e[1;34m$phrase \e[0m")
local greenl=$(echo -e "\e[1;32m$phrase \e[0m")
local cyanl=$(echo -e "\e[1;36$phrase \e[0m")
local redl=$(echo -e "\e[1;31m$phrase \e[0m")
local purplel=$(echo -e "\e[1;35m$phrase \e[0m")
local yellow=$(echo -e "\e[1;33m$phrase \e[0m")

case $color
in
   lack) echo $lack;;
   blue) echo $blue;;
   green) echo $green;;
   cyan) echo $cyan;;
   red) echo $red;;
   purple) echo $purple;;
   brown) echo $brown;;
   grayl) echo $grayl;;
   grayd) echo $grayd;;
   bluel) echo $bluel;;
   greenl) echo $greenl;;
   cyanl) echo $cyanl;;
   redl) echo $redl;;
   purplel) echo $purplel;;
   yellow) echo $yellow;;
   *) usage_error $0
esac;
}

## quotes around phrase are important
#echoc $1 "$2"
#exit 0
