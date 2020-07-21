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


E='echo -e';
e='echo -en';
trap "R;exit" 2
    ESC=$( $e "\e")
   TPUT(){ $e "\e[${1};${2}H";}
  CLEAR(){ $e "\ec";}
  CIVIS(){ $e "\e[?45l";}
   DRAW(){ $e "\e%@\e(0";}
  WRITE(){ $e "\e(B";}
   MARK(){ $e "\e[7m";}
 UNMARK(){ $e "\e[27m";}
      R(){ stty sane;$e "\e[37;210m\e[J";};
   HEAD(){ DRAW
           for each in $(seq 1 13);do
           $E "   x                                          x"
           done
           WRITE;MARK;TPUT 1 5
           $E "BASH SELECTION MENU";UNMARK;}
           i=0; CIVIS;NULL=/dev/null
   FOOT(){ MARK;TPUT 13 5
           printf "ENTER - SELECT,NEXT";UNMARK;}
  ARROW(){ read -s -n3 key 2>/dev/null >&2
           if [[ $key = $ESC[A ]];then echo up;fi
           if [[ $key = $ESC[B ]];then echo dn;fi;}
     M0(){ TPUT  3 2; $e "[*] Make a SQL dump in root project";}
     M1(){ TPUT  4 2; $e "[*] Make a zip archive";}
     M2(){ TPUT  5 2; $e "[*] Remove all cached + compiled files";}
     M3(){ TPUT  6 2; $e "[*] Remove all generated pictures";}
     M4(){ TPUT  7 2; $e "[*] Remove all Node.js files";}
     M5(){ TPUT  8 2; $e "[*] Remove all Composer files";}
     M6(){ TPUT  9 2; $e "[*] ( 3 -> 6 ) + 1 + 2 ";}
     M7(){ TPUT  10 2; $e "[*] About  ";}
     M8(){ TPUT  11 2; $e "[*] Exit   ";}
      LM=8
   MENU(){ for each in $(seq 0 $LM);do M${each};done;}
    POS(){ if [[ $cur == up ]];then ((i--));fi
           if [[ $cur == dn ]];then ((i++));fi
           if [[ $i -lt 0   ]];then i=$LM;fi
           if [[ $i -gt $LM ]];then i=0;fi;}
REFRESH(){ after=$((i+1)); before=$((i-1))
           if [[ $before -lt 0  ]];then before=$LM;fi
           if [[ $after -gt $LM ]];then after=0;fi
           if [[ $j -lt $i      ]];then UNMARK;M$before;else UNMARK;M$after;fi
           if [[ $after -eq 0 ]] || [ $before -eq $LM ];then
           M$before; M$after;fi;j=$i;UNMARK;M$before;M$after;}
   INIT(){ MENU;}
     SC(){ REFRESH;MARK;$S;$b;cur=`ARROW`;}
     ES(){ MARK;$e "ENTER = main menu ";$b;read;INIT;};INIT
  while [[ "$O" != " " ]]; do
  case $i in
        0) S=M0;SC;if [[ $cur == "" ]];then R;$e "\n$(w        )\n";ES;fi;;
        1) S=M1;SC;if [[ $cur == "" ]];then R;$e "\n$(ifconfig )\n";ES;fi;;
        2) S=M2;SC;if [[ $cur == "" ]];then R;$e "\n$(removeCachedDirectories)\n";ES;fi;;
        3) S=M3;SC;if [[ $cur == "" ]];then R;$e "\n$(route -n )\n";ES;fi;;
        4) S=M4;SC;if [[ $cur == "" ]];then R;$e "\n$(date     )\n";ES;fi;;
        5) S=M5;SC;if [[ $cur == "" ]];then R;$e "\n$($e by oTo)\n";ES;fi;;
        6) S=M6;SC;if [[ $cur == "" ]];then R;exit 0;fi;;
        7) S=M7;SC;if [[ $cur == "" ]];then R;$e "\n$($e by oTo)\n";ES;fi;;
        8) S=M8;SC;if [[ $cur == "" ]];then R;exit 0;fi;;
  esac;POS;done

set -e