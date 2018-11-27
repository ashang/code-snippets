#!/bin/sh
#
# unlinkdups  dirs...
#
# In the given files and directories, find any file with multiple hardlinks
# (hardlinked duplicates) and replace the file with a copy to break the
# hardlink.
#
# It will deal with each file it finds one file at a time, and will also
# handle symlinked symbolic links (whcih can be created by a 'cp -al' as used
# by the rsync backup technique.
#
# Options
#   -n   Dry Run, just report what files are duplicates
#   -q   Be Quiet, dont report the duplicate files.
#
# This is essentually the oppisite of the script "linkdups" which will find
# duplicate files (or hardlinked groups of files) and link them together to
# save disk space.
#
# NOTE: Some files should not be hardlinked together.  Configuration files,
# backups of files that are or will be edited or worked from.  SVN backups
# files, etc.   Similarly very small files (less than a disk block, typically
# 4Kbytes) will not save enough space to be worth hardlinking together.
#
# WARNING: does not handle files containing newlines correctly.
#
###
#
# Anthony Thyssen  -  27 April 2010
#
# Discover where the shell script resides
PROGNAME=`type "$0" | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname "$PROGNAME"`            # extract directory of program
PROGNAME=`basename "$PROGNAME"`          # base name of program

Usage() {                              # output the script comments as docs
  echo >&2 "$PROGNAME:" "$@"
  sed >&2 -n '/^###/q; /^#/!q; s/^#//; s/^ //; 3s/^/Usage: /; 2,$ p' \
          "$PROGDIR/$PROGNAME"
  exit 10;
}

VERBOSE=true    # report what files are duplicates

while [  $# -gt 0 ]; do
  case "$1" in
  --help|--doc*) Usage ;;

  -n) DRYRUN=true ;;
  -q) VERBOSE= ;;

  --) shift; break ;;    # end of user options
  -*) Usage "Unknown option \"$1\"" ;;
  *)  break ;;           # end of user options
  esac
  shift   # next option
done

temp_prefix='.#'
temp_postfix='~'
TEMP=''

# handle each hardlinked file (non-directory), one file at a time.
find "$@" \! -type d -links +1 | {

  # Automatic cleanup if interupted during copy
  trap "[ "X$TEMP" = "X" ] || rm -- "$TEMP"; exit 10;" 1 2 3 15
  trap "[ "X$TEMP" = "X" ] || rm -- "$TEMP"; exit 0;" 0

  while read file; do

    [ "$VERBOSE" ] && echo "$file"
    [ "$DRYRUN" ] && continue

    # work out a 'unique' temporary file in the same directory.
    basename="`expr "//$file" : '.*/\([^/]*\)'`"
    path="`expr "$file" : '\(.*\)/'`"
    : ${path:=.}

    tmp1="$path/$temp_prefix$basename$temp_postfix"
    tmp2="$tmp1" i=1
    while [ -e "$tmp2" ]; do
      tmp2="$tmp1${i}~"
      i=`expr $i = 1`
    done

    # copy the file appropriatally to break the harlink and move back
    TEMP="$tmp2"
    cp -a "$file" "$TEMP"
    mv "$TEMP" "$file"
    TEMP=''

  done
}

exit 0
