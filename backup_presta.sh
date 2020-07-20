#!/bin/bash

FILE="./app/config/parameters.php" 

if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist."
    set -e
fi

find ./ -name '*cart_default*' -delete
find ./ -name '*small_default*' -delete	
find ./ -name '*medium_default*' -delete	
find ./ -name '*home_default*' -delete	
find ./ -name '*large_default*' -delete	
find ./ -name '*category_default*' -delete	
find ./ -name '*stores_default*' -delete	
find ./ -name '*side_default*' -delete
find ./ --name '*LICENSE*' -delete

yes | rm -r ./install*
yes | rm -r ./app/cache/*
yes | rm -r ./app/test/*
yes | rm -r ./var/cache/*
yes | rm -r ./vendor/*
yes | rm -r ./**/vendor/*

find ./themes/**/assets/cache -type f -name '*.css' -delete
find ./themes/**/assets/cache -type f -name '*.js' -delete

while read line; do
	if echo "$line" | grep "database_host"
	then
		IFS='=' read -ra ADDR <<< "$line"
		DATABASE_HOST=${ADDR[1]//[,\'\ >]}
	fi
	if echo "$line" | grep "database_name"
	then
		IFS='=' read -ra ADDR <<< "$line"
		DATABASE_NAME=${ADDR[1]//[,\'\ >]}
	fi
	if echo "$line" | grep "database_user"
	then
		IFS='=' read -ra ADDR <<< "$line"
		DATABASE_USER=${ADDR[1]//[,\'\ >]}
	fi
	if echo "$line" | grep "database_password"
	then
		IFS='=' read -ra ADDR <<< "$line"
		DATABASE_PASSWORD=${ADDR[1]//[,\'\ >]}
	fi
done < $FILE

mysqldump -u $DATABASE_USER -p"${DATABASE_PASSWORD}" -h $DATABASE_HOST $DATABASE_NAME > $(date +%F)_$DATABASE_NAME.sql

zip -r /tmp/`date +%Y%m%d`_${PWD##*/}.zip ./ --exclude "*.git*" --exclude "*cache*"