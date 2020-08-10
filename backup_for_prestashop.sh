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
  if [ -f "$FILE" ]; then
      extractCredentials
      printCredentials
  else
      echo "$FILE does not exist."
      set -e
  fi
}

function removeGeneratedPictures() {
  echo "##-----------------------------------------------------"
  echo "## Remove Generated Pictures"
  echo "##-----------------------------------------------------\e[0m"
  find ./img/p -regextype sed -regex ".*/[0-9]*-[a-zA-Z_]*.jpg" -delete
  rm -rf ./img/tmp/*
}

function removeCachedDirectories() {
  echo "##-----------------------------------------------------"
  echo "## Remove Cached Directories"
  echo "##-----------------------------------------------------\e[0m"
  rm -rf ./install
  rm -rf ./app/cache/*
  rm -rf ./app/test/*
  rm -rf ./var/cache/*
}

function removeComposerDirectories() {

  COMPOSER_FILE="./composer.json"

  if [ ! -f "$COMPOSER_FILE" ]; then
      echo "${COMPOSER_FILE} is not found"
      return
  fi

  while read line; do

    PATH_COMPOSER=$( echo $line  | tr "\"" " " | awk '{ print $1 }' )
    SUBDIR=$( echo $PATH_COMPOSER | awk -F "/" '{print $2}')

    if [ -z "$SUBDIR" ]
    then
        continue
    fi
    if  [[ $PATH_COMPOSER == *"prestashop"* ]]
    then
        PATH_TO_DELETE="./modules/${SUBDIR}"
    else
        PATH_TO_DELETE="./vendor/${PATH_COMPOSER}"
    fi
    if  [ -d "$PATH_TO_DELETE" ]
    then
        rm -rf "${PATH_TO_DELETE}"
        echo "${PATH_TO_DELETE} has been deleted"
    fi

  done < $COMPOSER_FILE
}

function removeCompiledAssets() {
  echo "## Remove Compiled Assets"
  echo "## -----------------------------------------------------\e[0m"
  find ./themes/**/assets/cache -type f -name '*.css' -delete
  find ./themes/**/assets/cache -type f -name '*.js' -delete
}

function removeNodeDirectories() {
  echo "## Remove Node Modules Directories"
  echo "## -----------------------------------------------------\e[0m"
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
  local DUMP_NAME=$(date +%F)_$DATABASE_NAME.sql
  mysqldump -u $DATABASE_USER -p"${DATABASE_PASSWORD}" -h $DATABASE_HOST $DATABASE_NAME > $(date +%F)_$DATABASE_NAME.sql

  echo ""
  echo " Dump created in ${DUMP_NAME}"
  echo " ----------------------------------------------------\e[0m"
}

function createZipArchive() {
  local BACKUP_NAME=`date +%Y%m%d`_${PWD##*/}
  zip -r -9 /tmp/${BACKUP_NAME}.zip ./ --exclude "*.git*" --exclude "*.idea*"

  echo ""
  echo " Zip created at: /tmp/${BACKUP_NAME}.zip"
  echo " ----------------------------------------------------\e[0m"
}


printLogo
FILE="./app/config/parameters.php"
isConfFileExit

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
  echo "##-----------------------------------------------------"
  echo "## $menu ($REPLY)"
  echo "##-----------------------------------------------------"

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