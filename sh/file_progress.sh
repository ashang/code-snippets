#!/bin/sh
#
# file_progress -b -s {size} {file}
#
# Use lsof to get a progress report of the reading/writing of a (long) file.
# Normally the progress of a read is tracked, using the existing size of the
# file.  When writing you can specify the planned final size of the file,
# such as when downloading a file, or reading from a pipe.
#
# OPTIONS
#    -b    Show a percent bar
#    -s    planned final size of file
#
# EXAMPLE:
#    # ls -Fla
#    -rw-r--r-- 1 root sms 9427379750 Nov 17 23:59 audit.log
#    # bzip2 -q audit.log &
#
#    # file_progress audit.log
#
#    PID   SIZE        PCT CMD  FILE
#    21338 9427379750  56% bzip2 audit.log
#
# This command is very useful when repeated using something like "cycle"
# or "watch" to show a continuous progress report.
#
# Also see "pv" which is a pipeline progress report, where this
# script can be used any any time without needing fore-thought.
#
###
#
# Future: use some type of cache of previous run to track rate of progress
# though a specific file so that a estimate of the "time remaining" can be
# reported.
#
# 26 Nov 2015    Anthony Thyssen
#
# Discover where the shell script resides
PROGNAME=`type "$0" | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname "$PROGNAME"`            # extract directory of program
PROGNAME=`basename "$PROGNAME"`          # base name of program

Usage() {  # Report error and Synopsis line only
  echo >&2 "$PROGNAME:" "$@"
  sed >&2 -n '1,2d; /^###/q; /^#/!q; /^#$/q; s/^#  */Usage: /p;' \
          "$PROGDIR/$PROGNAME"
  exit 10;
}
Help() {   # Output Full header comments as documentation
  sed >&2 -n '1d; /^###/q; /^#/!q; s/^#//; s/^ //; p' \
          "$PROGDIR/$PROGNAME"
  exit 10;
}
Error() {  # Just output an error condition and exit (no usage)
  echo >&2 "$PROGNAME:" "$@"
  exit 2
}

while [  $# -gt 0 ]; do
  case "$1" in
  # Standard help option.
  -\?|-help|--help|--doc*) Help ;;

  -b) BAR=true ;;
  -s) shift; SIZE="$1" ;;

  --) shift; break ;;    # forced end of user options
  -*) Usage "Unknown option \"$1\"" ;;
  *)  break ;;           # unforced  end of user options
  esac
  shift   # next option
done

if [ ! -f "$1" ]; then
  Error "No such file: $1"
  exit 10
fi

# ----------------

lsof_info=$(
  lsof -F -o -- "$1" 2>/dev/null
  lsof -F -s -- "$1" 2>/dev/null
)

while read line; do
  [[ "$line" =~ ^(.)(.*)$ ]]
  type=${BASH_REMATCH[1]}
  value=${BASH_REMATCH[2]}
  case $type in
    p) pid="$value" ;;
    c) cmd="$value" ;;
    n) file="$value" ;;
    s) size="$value" ;;
    o) # value can start with   0t = decimal  0x = hexidecimal
       value=${value/#0t}  # just remove any '0t' prefix
       off=$[ value ] ;;   # save, converting it if hexidecimal
  esac
done <<< "$lsof_info"

if [ ! "$pid" ]; then
  Error "$PROGNAME: No process found or Access Denied"
  exit 0
fi

final_size="$size"
[ "$SIZE" ] && final_size=$SIZE
percent=$[ 100 * $off / $final_size ]

if [ "$BAR" ]; then
  echo "$pid  $size  $percent%  $cmd" |
     sed  -e :a -e 's/^.\{1,77\}$/ & /;ta'  # center text
  percent $percent "$file"
else
  ( echo "PID   SIZE   PCT        CMD"
    echo "$pid  $size  $percent%  $cmd"
  ) | column -o ' ' -t
  echo "$file"
fi

