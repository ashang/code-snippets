#!/bin/sh
#
# xwin_find [-v|-q] [timeout] window_name_regex
#
# Look for the given window (using an awk regular expression), and print the
# windows xwindow ID.  If a timeout is given (seconds) continue to look for
# the window to appear before returning its ID.
#
# If no such window is found output nothing, just exit with an error status.
#
# OPTIONS
#    -v    verbose, print the full matching xwininfo line on stderr
#    -a    print all the matching lines, not just the first
#    -q    do not print windows ID on stdout
#
# The script is typically used to wait for a specific application window to
# appear. The returned 'id' can then be used to modifiy the application
# using programs such as "xprop", "xwit", "wmctrl" and "xdotool".
#
# For example...
#
#   # Launch a firefox application
#   ( firefox & ) &
#
#   # wait for window to appear.
#   if id=`xwin_find 60 ".* Mozilla Firefox"`; then
#     echo "Main firefox window found (id=$id)"
#     # set the windows size and position and finally iconify it
#     xwit -resize 820 1000 -move 530 70 -iconify -id $id
#   else
#     echo >&2 "Timeout waiting for firefox window to appear.
#   fi
#
####
#
# Anthony Thyssen    September 2005
#
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
Usage() {
  echo >&2 "$PROGNAME:" "$@"
  sed >&2 -n '/^###/q; s/^#$/# /; 3s/^#/# Usage:/;  3,$s/^# //p;' \
          "$PROGDIR/$PROGNAME"
  exit 10;
}

timeout=   # just do one search and exit
indent=

if [ ! "$DISPLAY" ]; then
  echo >&2 "$PROGNAME: ERROR: X Windows not running -- ABORTING"
  exit 1
fi

while [  $# -gt 0 ]; do
  case "$1" in
  [0-9]*) timeout=`date +%s`
          timeout=`expr $timeout + $1 + 1` || Usage
          ;;
  -q)     QUIET=true ;;      # don't print the final window ID, just status
  -v)     VERBOSE=true ;;    # output the full xwininfo line on stderr
  -a)     PRINT_ALL=true ;;  # output all lines, not just the first
# -d)     shift; indent=`expr 2 + "$1" \* 3` ;;  # indent depth

  --)     shift; break ;;    # end of user options
  -*)     Usage "Unknown option \"$1\"" ;;
  *)      break ;;           # end of user options
  esac
  shift   # next option
done

[ $# -lt 1 ] && Usage "Missing window search regex"
[ $# -gt 1 ] && Usage "Too many arguments."

search="$1"

# -------Subroutines -----

find_win() {

  #if [ "$indent" ]; then
  #  # Look for window of specific depth on display
  #  line=`nice xwininfo -root -tree |\
  #          awk '/"'"$search"'":/ && /^ {'"$indent"'}[^ ]/ {print; exit}'`
  #fi
  exit='exit'; [ "$PRINT_ALL" ] && exit=''
  verbose=''   [ "$VERBOSE" ] && verbose='print > "/dev/stderr"'

  # nice'd the process to let it give way to starting processes
  nice xwininfo -root -tree |
    awk '/"'"$search"'":/ {      # find this title pattern
            '"$verbose"'         # output whole matching line
            print $1;            # the window ID
            '"$exit"'            # exit on first match?
         }'

}

# ------ Main Loop -----

# one search only
if [ -z "$timeout" ]; then
  find_win "$search"
  exit
fi

# wait until window appears
while :; do
  id=`find_win "$search"`

  if [ "$id" ]; then   # was the window ID found
    [ -z "$QUIET" ] && echo $id  # the window ID found
    exit 0;  # return success
  fi

  [ `date +%s` -ge $timeout ] && break
  usleep 100000
done

exit 1  # window was not found -- return failure

