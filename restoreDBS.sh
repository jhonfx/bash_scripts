#!/bin/bash
red='\E[31;47m'
green='\E[32;47m'
yellow='\E[33;47m'
blue='\E[34;47m'
magenta='\E[35;47m'
cyan='\E[36;47m'
white='\E[37;47m'
# Config Variables:
USER="root"
HOST="localhost"

# Read mysql root password:
#echo -n "Type mysql root password: "
#read -s PASS
#echo ""
:<<'COMMENT'
# Extract files from .gz archives:
function gzip_extract {

  for filename in *.gz
    do
      echo "extracting $filename"
      gzip -d $filename
    done
}

# Look for sql.gz files:
if [ "$(ls -A *.sql.gz 2> /dev/null)" ]  ; then
  echo "sql.gz files found extracting..."
  gzip_extract
else
  echo "No sql.gz files found"
fi

# Exit when folder doesn't have .sql files:
if [ "$(ls -A *.sql 2> /dev/null)" == 0 ]; then
  echo "No *.sql files found"
  exit 0
fi
COMMENT
# Get all database list first
DBS="$(mysql -u $USER -h $HOST -Bse 'show databases')"

echo "THESE ARE THE CURRENT EXISTING DATABASES:"
echo "________________________________________"
echo "$DBS"
echo "________________________________________"

# Ignore list, won't restore the following list of DB:
IGGY="test information_schema mysql"
# Restore DBs:
echo 'DATABASES FOR INSERT'
for filename in *.sql
do
  dbname=${filename%.sql}
  skipdb=-1
  echo "[$dbname]"

  if [ "$IGGY" != "" ]; then
    for ignore in $IGGY
    do
        [ "$dbname" == "$ignore" ] && skipdb=1 || :
    done
  fi
done

echo "__________________________________________"
echo "CHECKING IF EXIST ANY DATABASE OF THE LIST"
for filename in *.sql 
do
  dbname=${filename%.sql}
  skipdb=-1
  #evaluate the dblist
  if [ "$skipdb" == "-1" ] ; then
  
    skip_create=-1
    for existing in $DBS
    do      
      #echo "Checking database: $dbname to $existing"
      [ "$dbname" == "$existing" ] && skip_create=1 || :
    done
    
    if [ "$skip_create" ==  "1" ] ; then
      printf "DATABASE \033[1;31m$dbname\033[0m ALREADY EXIST, SKIPING CREATE\n"
    else
      echo "____________________________________________"
      echo "CREATE NEW DATABASES"
      printf "\033[1;92m[$dbname]\033[0m \n"
      
      echo "============================================"
      mysql -u root -e "create database $dbname"

      printf "IMPORTING DB: \033[1;92m[$dbname]\033[0m from $filename\n"
      mysql $dbname < $filename -u $USER
    fi
  fi
done