#!/bin/bash
# mybackup - Backup selected files & directories and email them as .tar.gz file to
# your email account.
# List of BACKUP files/dirs stored in file ~/.mybackup
#
# Usage   : ./mybackup
# 
# Notes   : Very handy tool to take backup (nowdays we have 1 gig+ email a/c)
# 
# Copyright (C) 2004 nixCraft project
# Email/Contact   : http://cyberciti.biz/fb/
# Date            : Aug-2004
# Last updated    : Aug-2005
# -------------------------------------------------------------------------
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
 
FILE=~/.mybackup
NOW=`date +"%d-%m-%Y"`
OUT="`echo $USER.$HOSTNAME`.$NOW.tar.gz"
TAR=`which tar`
 
# mail setup
MTO="nixbackup@somedom.com"
MSUB="Backup (`echo $USER @ $HOSTNAME`) as on `date`"
MES=~/tmp/mybackup.txt
MATT=~/tmp/$OUT
 
# make sure we put backup in our own tmp and not in /tmp
[ ! -d ~/tmp ] && mkdir ~/tmp || :
if [ -f $FILE ]; then
 IN="`cat $FILE | grep -E -v "^#"`"
else
 echo "File $FILE does not exists"
 exit 3
fi
 
if [ "$IN" == "" ]; then
 echo "$FILE is empty, please add list of files/directories to backup"
 echo "Use mybackupadd script"
 exit 2
fi
 
$TAR -zcf ~/tmp/$OUT $IN >/dev/null
# create message for mail
echo "Backup successfully done. Please see attached file." > $MES
echo "" >> $MES
echo "Backup file: $OUT" >> $MES
echo "" >> $MES
 
# bug fix, we can't send email with attachment if mutt is not installed
which mutt > /dev/null
if [ $? -eq 0 ]; then
 # now mail backup file with this attachment
 mutt -s "$MSUB" -a "$MATT" $MTO < $MES
else
 echo "Command mutt not found, cannot send an email with attachment"
fi
 
# clean up
/bin/rm -f $MATT
/bin/rm -f $MES
