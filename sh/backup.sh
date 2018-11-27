#!/bin/sh

PREF=/root/bin
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PREF
THIS_SCRIPT=`echo $0 | sed 's/^[\.|\/].*\///'`

##########################################################################################

SOURCES_TO_BACKUP="
--exclude-regexp sess_*
--exclude-regexp zend_cache---*
--exclude-regexp cache/cache.*

--include /etc
--include /root
--include /var/spool/cron
--include /var/lib/puppet
"
# A local directory to put backups in.
# /!\ Don't add a trailing slash
BACKUP_DIR=/Backups
TARGET_URL="file://$BACKUP_DIR"

# A local directory to restore files to.
RESTORE_DIR="$BACKUP_DIR/restore"

# A name that is used by duplicity. Set the symbolic name of the backup being operated on.
NAME=`hostname`
#NAME="Your_name_you_want"

# The main duplicity options
DUPLICITY_OPTIONS="--no-encryption --archive-dir=$BACKUP_DIR/.cache --name=$NAME"

# It forces a full backup if last full backup reaches a specified age.
MAX_AGE="1W"
DUPLICITY_OPTIONS="$DUPLICITY_OPTIONS --full-if-older-than $MAX_AGE"

# Set the size of backup chunks to VOLSIZE MB instead of the default 25MB.
# VOLSIZE must be number of MB's to set the volume size to.
VOLSIZE="500"
DUPLICITY_OPTIONS="$DUPLICITY_OPTIONS --volsize $VOLSIZE"

# Use this existing directory for duplicity temporary files instead of the system default,
# which is usually the /tmp directory. This option supersedes any environment variable.
TEMPDIR="$BACKUP_DIR/tmp"
[ ! -d $TEMPDIR ] && mkdir --parents $TEMPDIR
DUPLICITY_OPTIONS="$DUPLICITY_OPTIONS --tempdir $TEMPDIR"

# more duplicity command line options can be added in the following way
#DUPLICITY_OPTIONS="$DUPLICITY_OPTIONS --dry-run"

backup() {
    echo "Duplicity backing up..."
    echo ""
    DIFF=`verify 2>&1 | grep "0 differences found"`
    `echo " " > "$BACKUP_DIR"/backup.log`
    if [ -z "$DIFF" ]; then
	`duplicity $DUPLICITY_OPTIONS $SOURCES_TO_BACKUP --exclude '**' / $TARGET_URL > "$BACKUP_DIR"/backup.log`
    else
	echo "There is nothing to do."
	echo "-------------------------------------------------"
    fi
    echo "Removing duplicity backups older then $MAX_AGE"
    echo ""
    duplicity remove-older-than $MAX_AGE $DUPLICITY_OPTIONS --force $TARGET_URL
    echo "-------------------------------------------------"
    nixverify
}

list() {
    duplicity list-current-files $DUPLICITY_OPTIONS $TARGET_URL
}

status() {
    duplicity collection-status  $DUPLICITY_OPTIONS $TARGET_URL
}

verify() {
    duplicity verify $DUPLICITY_OPTIONS $SOURCES_TO_BACKUP --exclude '**' $TARGET_URL /
}

restore() {
    if [ -z "$1" ]; then
	echo "A path must be given to be restored relative to the root of the directory backed up."
	exit
    fi
    if [ -z "$2" ]; then
	RESTORED_TIME=""
    else
	RESTORED_TIME=`date -d "$2 $3 $4 $5 $6" +%Y-%m-%dT%H:%M:%S`
	echo "$RESTORED_TIME"
    fi
    RESTORED_PATH=`echo "$1" | sed 's/^\///'`
    RESTORE_INFO=`duplicity restore $DUPLICITY_OPTIONS -t $RESTORED_TIME --file-to-restore "$RESTORED_PATH" $TARGET_URL "$RESTORE_DIR/$RESTORED_PATH" 2>&1`
    if   [ -n "$(echo "$RESTORE_INFO" | grep "Errno 2")" ]; then
	[ ! -d "$RESTORE_DIR/$RESTORED_PATH" ] && mkdir -p "$RESTORE_DIR/$RESTORED_PATH"
	duplicity restore $DUPLICITY_OPTIONS --file-to-restore "$RESTORED_PATH" $TARGET_URL "$RESTORE_DIR/$RESTORED_PATH"
    elif [ -n "$(echo "$RESTORE_INFO" | grep "Will not overwrite")" ]; then
	echo "$RESTORE_INFO"
	echo ""
	echo "Just delete the restore directory first: \"$RESTORE_DIR\""
    else
	echo "$RESTORE_INFO"
    fi
}

nixverify() {
    `md5sum "$BACKUP_DIR"/duplicity-* > "$BACKUP_DIR"/nixverify.md5`
    BACKUP_DATE=`date +%Y-%m-%dT%H:%M:%S.%N`
    `echo "$BACKUP_DATE" > "$BACKUP_DIR"/nixverify.date`
    `echo "$NAME" >> "$BACKUP_DIR"/nixverify.date`
    `echo "$BACKUP_DIR" >> "$BACKUP_DIR"/nixverify.date`

}

usage() {
cat << EOF
SYNOPSIS:
  $THIS_SCRIPT [COMMAND]

DESCRIPTION:
  $THIS_SCRIPT is a script to backup, list and restore files by using duplicity.

COMMANDS:
    $THIS_SCRIPT backup|bkp
	Start backing up.

    $THIS_SCRIPT list|ls
	Lists the files currently backed up in the archive.

    $THIS_SCRIPT status|stat|st
	Summarize the status of the backup repository by printing
	the chains and sets found, and the number of volumes in each.

    $THIS_SCRIPT verify|vrf
	Enter verify mode.

    $THIS_SCRIPT restore|rre path_to_be_restored [Restore time. Example: 2011-01-24T11:24:00]
	Enter restore mode.
	path should be given relative to the root of the directory backed up.

    $THIS_SCRIPT nixverify|nixver
EOF
}

case "$1" in
    backup|bkp)
	backup
    ;;
    list|ls)
	list
    ;;
    status|stat|st)
	status
    ;;
    verify|vrf)
	verify
    ;;
    restore|rre)
	restore $2 $3 $4 $5 $6 $7
    ;;
    nixverify|nixver)
	nixverify
    ;;
    *)
	usage
esac
