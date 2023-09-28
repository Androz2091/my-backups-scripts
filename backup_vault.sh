#!/bin/bash

TIMESTAMP=`date +%F-%H%M`

# Directory to archive
SOURCE_DIR="/home/debian/services/vaultwarden/data"
BACKUP_NAME="vault-$TIMESTAMP"
BACKUPS_DIR="/home/debian/VAULT_BACKUPS"

# Remote server
REMOTE_HOST_USERNAME="androz"
REMOTE_HOST_ADDRESS=""
REMOTE_HOST_PATH="/home/androz/vault_backups"

# remove old files, except for the previous tar gz file
find $BACKUPS_DIR/ ! -name *.tar.gz -type f -exec rm -f {} +

# Create the archive
mkdir $BACKUPS_DIR/$BACKUP_NAME
sqlite3 $SOURCE_DIR/db.sqlite3 ".backup '$BACKUPS_DIR/$BACKUP_NAME/db.sqlite3'"
cp -r $SOURCE_DIR/attachments $BACKUPS_DIR/$BACKUP_NAME
cp -r $SOURCE_DIR/sends $BACKUPS_DIR/$BACKUP_NAME
cp -r $SOURCE_DIR/*.pem $BACKUPS_DIR/$BACKUP_NAME
tar -zcvf $BACKUPS_DIR/$BACKUP_NAME.tar.gz $BACKUPS_DIR/$BACKUP_NAME

# Remove the dir with the files in the archive
rm -rf $BACKUPS_DIR/$BACKUP_NAME

# Sync with remote server
rsync -avz -e ssh $BACKUPS_DIR $REMOTE_HOST_USERNAME@$REMOTE_HOST_ADDRESS:$REMOTE_HOST_PATH

# Delete the archives (except the current one) from the backups dir
find $BACKUPS_DIR/ ! -name $BACKUP_NAME.tar.gz -type f -exec rm -f {} +

# Log
echo "Backup of cloud completed"
