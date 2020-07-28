#!/bin/bash -ex

function printLogo {
  echo -e "
  \e[38;5;60m ___                _          \e[38;5;196m    _          _ __
  \e[38;5;61m| _ \ _ _  ___  ___| |_  __ _  \e[38;5;197m___| |_   ___ | '_ \\
  \e[38;5;62m|  _/| '_|/ -_)(_-/|  _|/ _\` |\e[38;5;198m(_-/|   \ / _ \| .__/
  \e[38;5;63m|_|  |_|  \___|/__/ \__|\__/_|\e[38;5;199m/__/|_||_|\___/|_|
  "
}

function isConfFileExit {
  if [ -f "$1" ]; then
      echo "$1 exists."
  else
      echo "$1 does not exist."
      set -e
  fi
}

function removeGeneratedPictures() {
  printf "##-----------------------------------------------------\n"
  printf "## Remove Generated Pictures\n"
  printf "##-----------------------------------------------------\n"
  find ./ -name '*cart_default*' -delete
  find ./ -name '*small_default*' -delete
  find ./ -name '*medium_default*' -delete
  find ./ -name '*home_default*' -delete
  find ./ -name '*large_default*' -delete
  find ./ -name '*category_default*' -delete
  find ./ -name '*stores_default*' -delete
  find ./ -name '*side_default*' -delete
}

function removeCachedDirectories() {
  printf "##-----------------------------------------------------\n"
  printf "## Remove Cached Directories\n"
  printf "##-----------------------------------------------------\n"
  rm -rf ./install*
  rm -rf ./app/cache/*
  rm -rf ./app/test/*
  rm -rf ./var/cache/*
}

function removeComposerDirectories() {
  printf "##-----------------------------------------------------\n"
  printf "## Remove Composer Directories\n"
  printf "##-----------------------------------------------------\n"
  rm -rf ./vendor/*
  rm -rf ./**/vendor/*
}

function removeCompiledAssets() {
  printf "##-----------------------------------------------------\n"
  printf "## Remove Compiled Assets\n"
  printf "##-----------------------------------------------------\n"
  find ./themes/**/assets/cache -type f -name '*.css' -delete
  find ./themes/**/assets/cache -type f -name '*.js' -delete
}

function removeNodeDirectories() {
  find . -type d -name 'node_modules' -exec rm -r {} +
}

function extractCredentials() {

  DATABASE_HOST=$(awk '/database_host/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
  DATABASE_NAME=$(awk '/database_name/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
  DATABASE_USER=$(awk '/database_user/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
  DATABASE_PASSWORD=$(awk '/database_password/ {print $3}' $FILE | sed "s/[^[:alnum:]-]//g")
}

function printCredentials() {
  echo "-----CREDENTIAL-------"
  echo $DATABASE_USER
  echo $DATABASE_NAME
  echo $DATABASE_USER
  echo $DATABASE_PASSWORD
}


function createDumpDB() {
  mysqldump -u $DATABASE_USER -p"${DATABASE_PASSWORD}" -h $DATABASE_HOST $DATABASE_NAME > $(date +%F)_$DATABASE_NAME.sql
}

function createZipArchive() {
  zip -r /tmp/`date +%Y%m%d`_${PWD##*/}.zip ./ --exclude "*.git*" --exclude "*cache*"
}


printLogo
FILE="./app/config/parameters.php"
isConfFileExit ${FILE}

options=(
'Make a SQL dump in root project'
'Make a zip archive'
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
    2) removeCachedDirectories;;
    2) removeGeneratedPictures;;
    2) removeNodeDirectories;;
    2) removeComposerDirectories;;
    2) createDumpDB;createZipArchive;removeCachedDirectories;removeGeneratedPictures;removeNodeDirectories;removeComposerDirectories;createDumpDB;createZipArchive;;
    2) echo 'Please check README';;
    2) exit 0;;
  esac

done