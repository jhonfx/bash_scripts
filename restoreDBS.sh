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
DBS="$(mysql -u $USER -h $HOST -p$PASS -Bse 'show databases')"

echo "These are the current existing Databases:"
echo $DBS

# Ignore list, won't restore the following list of DB:
IGGY="test information_schema mysql"
:<<'COMMENT'
COMMENT
# Restore DBs:
echo 'Databases for insert'
for filename in *.sql
do
  dbname=${filename%.sql}
  echo $dbname
    echo "making new databases"
    mysql -u root -p -e "create database $dbname"

    echo "Importing DB: $dbname from $filename"
    mysql $dbname < $filename -u $USER -p$PASS
done