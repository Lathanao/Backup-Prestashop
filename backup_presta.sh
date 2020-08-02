#!/bin/bash -ex

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  |                                                                       |
##  | Copyright (c) 2020 Tanguy SALMON                                      |
##  | Version 0.2                                                           |
##  | MIT License, See LICENSE.md                                           |
##  |                                                                       |
##  +-----------------------------------------------------------------------+

##
##	DESCRIPTION:
##	This script allow to reduce the size of the main directory of your
##  Prestashop project.
##	Then make a backup.
##

##
##	TODO:
##	Test if can remove img/tmp/*
##	CronJOb
##  Send Archive on Gdrive
##	Set zip compression
##	Clean DB
##	Remove empty dir in img/p
##	Remove dir following composer.json (eg Prestashop/ps_modules)
##

function printLogo {
  echo -e "
  \e[38;5;60m ___                _          \e[38;5;196m    _          _ __
  \e[38;5;61m| _ \ _ _  ___  ___| |_  __ _  \e[38;5;197m___| |_   ___ | '_ \\
  \e[38;5;62m|  _/| '_|/ -_)(_-/|  _|/ _\` |\e[38;5;198m(_-/|   \ / _ \| .__/
  \e[38;5;63m|_|  |_|  \___|/__/ \__|\__/_|\e[38;5;199m/__/|_||_|\___/|_|
  \e[38;5;45m"
}

function isConfFileExit {
  if [ -f "$1" ]; then
      extractCredentials
      printCredentials
  else
      echo "$1 does not exist."
      set -e
  fi
}

function removeGeneratedPictures() {
  printf "##-----------------------------------------------------\n"
  printf "## Remove Generated Pictures\n"
  printf "##-----------------------------------------------------\n\e[0m"
  find ./ -name '*cart_default*' -delete
  find ./ -name '*small_default*' -delete
  find ./ -name '*medium_default*' -delete
  find ./ -name '*home_default*' -delete
  find ./ -name '*large_default*' -delete
  find ./ -name '*category_default*' -delete
  find ./ -name '*stores_default*' -delete
  find ./ -name '*side_default*' -delete
  rm -rf ./img/tmp/*
}

function removeCachedDirectories() {
  printf "##-----------------------------------------------------\n"
  printf "## Remove Cached Directories\n"
  printf "##-----------------------------------------------------\n\e[0m"
  rm -rf ./install*
  rm -rf ./app/cache/*
  rm -rf ./app/test/*
  rm -rf ./var/cache/*
}

function removeComposerDirectories() {
  printf "## Remove Composer Directories\n"
  printf "## -----------------------------------------------------\n\e[0m"
  rm -rf ./vendor/*
  rm -rf ./**/vendor/*
}

function removeCompiledAssets() {
  printf "## Remove Compiled Assets\n"
  printf "## -----------------------------------------------------\n\e[0m"
  find ./themes/**/assets/cache -type f -name '*.css' -delete
  find ./themes/**/assets/cache -type f -name '*.js' -delete
}

function removeNodeDirectories() {
  printf "## Remove Node Modules Directories\n"
  printf "## -----------------------------------------------------\n\e[0m"
  find . -type d -name 'node_modules' -exec rm -r {} +
}

function extractCredentials() {
  DATABASE_HOST=$(awk '/database_host/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
  DATABASE_NAME=$(awk '/database_name/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
  DATABASE_USER=$(awk '/database_user/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
  DATABASE_PASSWORD=$(awk '/database_password/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
}

function printCredentials() {
  echo "##"
  echo "## CREDENTIAL PRESTASHOP DETECTED"
  echo "## ----------------------------------------------------"
  echo "database_host => $DATABASE_HOST"
  echo "database_name => $DATABASE_NAME"
  echo "database_user => $DATABASE_USER"
  echo "database_password => $DATABASE_PASSWORD"
  echo "\e[0m"
}

function createDumpDB() {
  echo "##"
  echo "## DUMP BD"
  echo "## ----------------------------------------------------\e[0m"

  mysqldump -u $DATABASE_USER -p"${DATABASE_PASSWORD}" -h $DATABASE_HOST $DATABASE_NAME > $(date +%F)_$DATABASE_NAME.sql

  echo ""
  echo " Dump created in root directory project"
  echo " ----------------------------------------------------\e[0m"
}

function createZipArchive() {
  local BACKUP_NAME=`date +%Y%m%d`_${PWD##*/}
  echo "##"
  echo "## ZIP ARCHIVE CREATION"
  echo "## ----------------------------------------------------\e[0m"

  zip -r -9 /tmp/${BACKUP_NAME}.zip ./ --exclude "*.git*" --exclude "*.idea*"

  echo ""
  echo " Zip created at: /tmp/${BACKUP_NAME}.zip"
  echo " ----------------------------------------------------\e[0m"
}


printLogo
FILE="./app/config/parameters.php"
isConfFileExit ${FILE}

options=(
'Make a SQL dump in root project'
'Make a zip archive in /tmp project'
'Remove all cached + compiled files'
'Remove all generated pictures'
'Remove all Node.js files'
'Remove all Composer files'
'( 3 -> 6 ) + 1 + 2'
'About'
'Exit'
)

select menu in "${options[@]}";
do
  echo "##-----------------------------------------------------\n"
  echo "## $menu ($REPLY)\n"
  echo "##-----------------------------------------------------\n"

  case $REPLY in
    1) createDumpDB;;
    2) createZipArchive;;
    3) removeCachedDirectories;;
    4) removeGeneratedPictures;;
    5) removeNodeDirectories;;
    6) removeComposerDirectories;;
    7) removeCachedDirectories;removeGeneratedPictures;removeNodeDirectories;removeComposerDirectories;createDumpDB;createZipArchive;;
    8) echo 'Please check README';;
    9) exit 0;;
  esac
done