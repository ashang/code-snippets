#!/bin/sh
#
# percent  num  [title]
# percent  numerator denominator title
#
# Print an ASCII "percentage used" bar with the percentage given centered on
# a normal 80 character TTY display. (EG: centered in 72 columns) Optionally
# center the title above the percentage bar.
#
# Idea by some unknown student at Griffith University
# Completely re-written several times by Anthony Thyssen
# Inital dependancy on perl added due to brain-dead MacOSX "expr"
#
PATH="/usr/ucb:/usr/bin:/usr/5bin:$PATH"
export PATH

# Check that it is a number
arg1=`expr "$1" : '\(-*[0-9][0-9]*\)' 2>/dev/null`
if [ ! "$arg1" ]; then
  echo >&2 "Percentage given is not a number!"
  echo >&2 "Usage: percent  number  [title]"
  echo >&2 "       percent  numerator denominator title"
  exit 10
fi
arg2=`expr "$2" : '\(-*[0-9][0-9]*\)' 2>/dev/null`

# get the arguments
case $# in
  1) percent=$arg1 ;;
  2) percent=$arg1; title="$2" ;;
  3) percent=`expr 100 \* $arg1 / $arg2`; title="$3" ;;
  *) echo >&2 "Usage: percent  num  [title]"
     exit 10 ;;
esac

# half the percentage value --> number chars!
# figure out number of characters to output (100% = 50 char)
chars=`expr "$percent" / 2 + 1`

rule="|----+----+----+----+----|----+----+----+----+----|"
char="#"; equal="|"; more=">"; less="<";
B= N= Gon= Goff=

# ----------------------------
# Get terminal charactistics...
if [ -t 1 -a "X$TERM" != "X" -a "X$TERM" != 'Xdumb' ]; then
  B="`tput bold 2>/dev/null`"        # bold ON
  N="`tput sgr0 2>/dev/null`"        # all attributes OFF

  # For get this, too many terminals don't do this right
  # As such I will handle specific terminals ourselves
  #Gon="`tput smacs`"     # Graphic chars set ON
  #Goff="`tput rmacs`"    # Graphic chars set OFF
  #tput enacs   # enable alturnative characters - ???

  case "$TERM" in
  vs100|xterm*)
    Gon="(0"; Goff="(B"
    rule="${Gon}tqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqu${Goff}"
    char="a"; equal="x"; more=">"; less="<";
    ;;
  dtterm) # CDE Terminals do not have a graphic "a"!
    Gon="(0"; Goff="(B"
    rule="${Gon}tqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqnqqqqu${Goff}"
    char="#"; equal="|"; more=">"; less="<";
    ;;
  esac
fi

# ----------------------------
# print the percentage bar
over=`perl -e "print '$char' x 50, '$equal$more'"`
line=`perl -e "print '$char' x 50, '$equal'"`

if [ "$title" ]; then
  p=`perl -e '$p=(73-length("'"$title"'"))/2; $p = 0 if $p < 0; print " " x $p'`
  echo "$p$title"   # print the centered title
fi

# Rulers are 52 characters, figure out the indent prefix to use.
# Prefix for rulers is one less so we can add an extra (below zero) character
p=`perl -e "print ' ' x 9"`  # (72-52)/2 - 1  =>  9 character prefix
echo "$p ${B}0$N   10   20   30   40   ${B}50$N   60   70   80   90   ${B}100$N"
echo "$p $rule"

# print the actual guage
if [ $percent -lt 0 ]; then
  echo "$p$Gon$less$equal$Goff"
elif [ $percent -eq 0 ]; then
  echo "$p $Gon$equal$Goff"
elif [ $percent -gt 100 ]; then
  echo "$p $Gon$over$Goff"
else
  # expr replaced by perl equivelent, due to brain dead MacOSX expr command
  #echo "$p$Gon`expr substr "$line" 1 $chars`$Goff"
  echo "$p $Gon"`perl -e "print substr('$line', 0, $chars)"`"$Goff"
fi

