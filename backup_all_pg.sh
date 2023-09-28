  GNU nano 5.4                                                                       ../backup_pg.sh                                                                                 
#!/bin/bash

TIMESTAMP=`date +%F-%H%M`

PG_PATH="/usr/lib/postgresql/15/bin/pg_dump"
PG_USER=""
PG_PASSWORD=""

printenv

REMOTE_HOST_USERNAME="androz"
REMOTE_HOST_ADDRESS=""
REMOTE_HOST_PATH="/home/androz/backups"

echo 'a'
echo "PGPASSWORD='$PG_PASSWORD' psql -U $PG_USER -h localhost -d postgres -t -c 'select datname from pg_database where not datistemplate' | grep '\S' | awk NF"

for db in `PGPASSWORD="$PG_PASSWORD" psql -U $PG_USER -h localhost -d postgres -t -c 'select datname from pg_database where not datistemplate' | grep '\S' | awk NF`; do

    BACKUPS_DIR="/home/debian/PG_BACKUPS/$db"
    BACKUP_NAME="$db-$TIMESTAMP"

    # Make the backups directory if it doesn't exist
    mkdir -p $BACKUPS_DIR

    # Dump the Postgres database
    PGPASSWORD=$PG_PASSWORD $PG_PATH -F p -f $BACKUPS_DIR/$BACKUP_NAME.sql -U $PG_USER $db -h localhost

    # Make a tar file of the dump
    tar -zcvf $BACKUPS_DIR/$BACKUP_NAME.tar.gz $BACKUPS_DIR/$BACKUP_NAME.sql

    # Synchronize the backups folder with the remote server (send the missing file)
    rsync -avz --exclude='*.sql' -e ssh $BACKUPS_DIR $REMOTE_HOST_USERNAME@$REMOTE_HOST_ADDRESS:$REMOTE_HOST_PATH

    # Then delete the rest of the files
    find $BACKUPS_DIR/ ! -name $BACKUP_NAME.sql -type f -exec rm -f {} +

    # Log
    echo "Backup of $db database completed"

done
