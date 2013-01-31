#!/bin/sh
####################################
#
# Drupal Specific Backup Script.
#
####################################

# What to backup.
backup_files="/var/www/vhosts/website.com/httpdocs"

# Where to backup to.
dest="/var/www/vhosts/website.com/backups/files"

# Create archive filename.
day=$(date +%m-%d-%Y)
archive_file="website.com-$day.tgz"

# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo

# Backup the files using tar.
tar czf $dest/$archive_file $backup_files

MyUSER="website.com" # USERNAME
MyPASS="website.com" # PASSWORD
MyHOST="localhost" # Hostname

# Linux bin paths, change this if it can not be autodetected via which command
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"

# Backup Dest directory, change this if you have someother location
DEST="/var/www/vhosts/website.com/backups"

# Main directory where backup will be stored
MBD="$DEST/db"

# Get hostname
HOST="$(hostname)"

# Get data in dd-mm-yyyy format
NOW="$(date +"%d-%m-%Y")"

# File to store current backup file
FILE=""

# Store list of databases
DBS="website.com"

# DO NOT BACKUP these databases
IGGY="test"

[ ! -d $MBD ] && mkdir -p $MBD || :

# Only root can access it!
$CHOWN 0.0 -R $DEST
$CHMOD 0600 $DEST

# Get all database list first
DBS="$($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"

for db in $DBS
do
skipdb=-1
if [ "$IGGY" != "" ];
then
for i in $IGGY
do
[ "$db" == "$i" ] && skipdb=1 || :
done
fi

if [ "$skipdb" == "-1" ] ; then
FILE="$MBD/$db.$day.sql.gz"
# do all inone job in pipe,
# connect to mysql using mysqldump for select mysql database
# and pipe it out to gz file in backup dir :)
$MYSQLDUMP -u $MyUSER -h $MyHOST -p$MyPASS $db | $GZIP -9 > $FILE
fi
done

# To delete files older than 8 days
find /var/www/vhosts/website.com/backups/files -type f -mtime +8 -exec rm {} \;
find /var/www/vhosts/website.com/backups/db -type f -mtime +8 -exec rm {} \;

# Print end status message.
echo
echo "Backup finished"
date