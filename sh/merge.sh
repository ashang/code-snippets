#!/bin/sh -
#
# merge -- Non-destructive Move (Copy) files
#
# Usage: merge [-c] from to
#        merge [-c] files... dir
# Options: -c  copy instead of move the files
#
#   This is equivelant to a 'mv' operation except that files which would
# overwrite an existing file (IE: file is destination directory has the
# same name as a file being moved) will be renamed by appending a number
# to it.  The user is given a message when such renaming occurs, so
# appropiate action can be taken.  This is so that no file is destroyed
# by a normal `mv' command especially when merging two directories of
# filenames.
#
####
#
# Author:    Anthony Thyssen  <anthony@cit.gu.edu.au>
#
# Discover where the shell script resides
PROGNAME=`type "$0" | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname "$PROGNAME"`            # extract directory of program
PROGNAME=`basename "$PROGNAME"`          # base name of program
Usage() {                                # output the script comments as docs
  echo >&2 "$PROGNAME:" "$@"
  sed >&2 -n '/^###/q; /^#/!q; s/^#//; s/^ //; 3s/^/Usage: /; 2,$ p' \
          "$PROGDIR/$PROGNAME"
  exit 10;
}

sep=':'     # field separator for internal filename list ( ':' for debug )
attach='.'  # string put between original name and appended number (dups)
cmd="mv"

while [  $# -gt 0 ]; do
  case "$1" in
  --help|--doc*) Usage ;;
  -c) cmd="cp" ;;

  --) shift; break ;;    # forced end of user options
  -*) Usage "Unknown option \"$1\"" ;;
  *)  break ;;           # unforced  end of user options
  esac
  shift   # next option
done

doit() {
  if [ -f "$2/$3" ]; then
    if false; then
      # MOVE/COPY by adding a numbered suffix  -- NEEDS IMPROVEMENT
      n=2              # index for multiple items
      while f="$3$attach$n"; [ -e "$2/$f" ]; do
        n=`expr $n + 1`
      done
      [ $n -gt 1 ] && echo "file \"$3\" exists -> renamed \"$f\""
      $cmd -- "$1" "$2/$f"
    else
      # Do nothing -- don't move duplicates
      echo "file \"$3\" exists --SKIPPING!"
    fi
  else
    # no problem just do it
    $cmd -- "$1" "$2/$3"
  fi
}

case $# in
 0|1)
  echo "merge: Too few arguments!" >&2
  usage
  ;;
 2) # handle direct filename to filename when arg 2 is not a directory
   if [ ! -d "$2" ]; then
     case $2 in
       /*) # Gad! -- a absolute filename given just move it
           doit "$1" "" "$2" ;;
       *)  # ok just a relative filename move it to directory `.'
           doit "$1" "." "$2" ;;
     esac
     exit 0
   fi
   ;;
esac

# Go collect the options to get to the last option.
files="$1"; shift   # first arg must be a filename to move/copy
dir="$1"; shift     # assume arg 2 is destination (sort it out below)

while [ $# -gt 0 ]; do
  files="$files$sep$dir"  # append the non-destination to file list
  dir="$1"                # assume this is the destionation
  shift
done

# debugging -- check what is read in (change $sep above for testing)
# echo "dir=$dir"
# echo "files=$files"

if [ ! -d "$dir" ]; then
  echo "merge: multiple files given, but destination is not a directory" >&2
  usage
fi

oldIFS=$IFS; IFS="$sep"; set -- $files; IFS=$oldIFS

# For each file in list (now that we have a destination) move/copy it
for i in "$@"; do
  doit "$i" "$dir" "`basename "$i"`"
done

