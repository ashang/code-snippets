#!/bin/sh
#
# locate  -- a header file for shell programs
#
# Small Script you can add to the beginning of your shell programs to 
# determine the location of the script.  This lets you find things like
# configuration files relative to the scripts location, or read the script
# itself for things like self-documenting manuals (something I do a lot).
# 
# It has worked for me for more than 30 years! And I have used it on
# Sun3, Sun4, Ultrix, Solaris, Linux, MacOSX, with bourne shells, dash, 
# bash, ksh, and zsh.  It should work for any Unix-like environment.
# 
# Technically locating a running script has no solution, as it could be a 
# piped into a shell, but in practice it does work.
#
# See BASHFAQ:   http://mywiki.wooledge.org/BashFAQ/028
#
####
#
# Simple -- Just the program name
#PROGNAME=`basename $0` # Program basename - path may not exist or be relative
#PROGDIR=`dirname $0`   # directory of script (may be relative)
#
# Use BASH_SOURCE or search for script on the users path
# Warning this does not syntax highlight very well. :-(
#PROGNAME="${BASH_SOURCE:-`type $0 | awk '{print $3}'`}"

# Discover where the shell script resides
PROGNAME=`type $0 | awk '{print $3}'`  # ask the shell 
PROGDIR=`dirname "$PROGNAME"`          # extract directory of program
PROGNAME=`basename "$PROGNAME"`        # base name of program

if [ ! -f "$PROGDIR/$PROGNAME" ]; then # This has NEVER happened to me!
   echo >&2 "$PROGNAME: Unable to locate the script -- ABORTING"
   exit 10
fi

# Fully qualify directory path (remove relative components and symlinks)
# This is important if you plan to change directories
# if "type"
# NOTE: bash "pwd" only returns the users 'logical path' though symlinks.
# But "pwd -P" works as a bash builtin, or as a binary command
PROGDIR=`cd "$PROGDIR" && pwd -P`
ORIGDIR=`pwd -P`

# Using  "readlink -f"  if available. It is not a bash built-in
#ORIGDIR=`readlink -f .`
#PROGDIR=`readlink -f "$PROGDIR"`


# Where do you want to be running?
# Caution: Any user provided file arguments should be accessed
# relative to the original directory ($ORIGDIR)
#cd "$PROGDIR"

# Get a config file relative to scripts location (without cd)
# config="$PROGDIR/../etc/$PROGNAME.conf"
# config=`readlink -f "$config"`     # clean up path

# -------------------------------------------------
# Check the arguments being used
#
#echo "BASH_SOURCE  : $BASH_SOURCE"
echo "GIVEN NAME   : $0"
echo "PROGNAME     : $PROGNAME"
echo "LOCATED AT   : $PROGDIR"
echo "CALLING FROM : $ORIGDIR"

# -------------------------------------------------

