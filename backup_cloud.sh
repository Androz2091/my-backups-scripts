#!/bin/bash

TIMESTAMP=`date +%F-%H%M`

# Directory to archive
SOURCE_DIR="/home/debian/services/cloud/files"
BACKUP_NAME="cloud-$TIMESTAMP"
BACKUPS_DIR="/home/debian/CLOUD_BACKUPS"

# Remote server
REMOTE_HOST_USERNAME="androz"
REMOTE_HOST_ADDRESS=""
REMOTE_HOST_PATH="/home/androz/cloud_backups"

# Create the archive
tar -zcvf $BACKUPS_DIR/$BACKUP_NAME.tar.gz $SOURCE_DIR

# Sync with remote server
rsync -avz -e ssh $BACKUPS_DIR $REMOTE_HOST_USERNAME@$REMOTE_HOST_ADDRESS:$REMOTE_HOST_PATH

# Delete the archives (except the current one) from the backups dir
find $BACKUPS_DIR/ ! -name $BACKUP_NAME.tar.gz -type f -exec rm -f {} +

# Log
echo "Backup of cloud completed"
