#!/bin/bash

function printLogo {
  echo -e "
   ___                _              _          _ __
  | _ \ _ _  ___  ___| |_  __ _  ___| |_   ___ | '_ \\
  |  _/| '_|/ -_)(_-/|  _|/ _\` |(_-/|   \ / _ \| .__/
  |_|  |_|  \___|/__/ \__|\__/_|/__/|_||_|\___/|_|
  "
}

function regexAttributeValue {
  echo "$1" | grep -oE '[^ ]+$' | sed "s/[^[:alnum:]-]//g"
}

function isConfFileExit {
  if [ -f "$1" ]; then
      echo "$1 exists."
  else
      echo "$1 does not exist."
      set -e
  fi
}

FILE="./app/config/parameters.php"


function removeGeneratedPictures {
  find ./ -name '*cart_default*' -delete
  find ./ -name '*small_default*' -delete
  find ./ -name '*medium_default*' -delete
  find ./ -name '*home_default*' -delete
  find ./ -name '*large_default*' -delete
  find ./ -name '*category_default*' -delete
  find ./ -name '*stores_default*' -delete
  find ./ -name '*side_default*' -delete
  find ./ --name '*LICENSE*' -delete
}

function removeCachedDirectories {
  yes | rm -r ./install*
  yes | rm -r ./app/cache/*
  yes | rm -r ./app/test/*
  yes | rm -r ./var/cache/*
  yes | rm -r ./vendor/*
  yes | rm -r ./**/vendor/*
}

function deleteCompiledAsstes {
  find ./themes/**/assets/cache -type f -name '*.css' -delete
  find ./themes/**/assets/cache -type f -name '*.js' -delete
}
printLogo
isConfFileExit ${FILE}
#removeGeneratedPictures
#deleteCompiledAsstes

while read LINE; do
  case $(echo ${LINE} | grep -Eo '^[^ ]+' ) in
    \'database_host\') DATABASE_HOST=$(regexAttributeValue "${LINE}") ;;
    \'database_name\') DATABASE_NAME=$(regexAttributeValue "${LINE}") ;;
    \'database_user\') DATABASE_USER=$(regexAttributeValue "${LINE}") ;;
    \'database_password\') DATABASE_PASSWORD=$(regexAttributeValue "${LINE}") ;;
  esac
done < $FILE

echo "------------"
echo $DATABASE_USER
echo $DATABASE_NAME
echo $DATABASE_USER
echo $DATABASE_PASSWORD

#mysqldump -u $DATABASE_USER -p"${DATABASE_PASSWORD}" -h $DATABASE_HOST $DATABASE_NAME > $(date +%F)_$DATABASE_NAME.sql
#
#zip -r /tmp/`date +%Y%m%d`_${PWD##*/}.zip ./ --exclude "*.git*" --exclude "*cache*"


