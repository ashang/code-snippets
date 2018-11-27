#!/bin/sh
#
#   shell_expect expect_data log_file | command > log_file
#
# Using the lines in file "expect_data" send requests to the command (such as
# "telnet"), and check its output "log_file" for expected strings, (or a timed
# delay), before continuing.
#
# Syntax of "expect_data"
#
#   S request_string
#   E[delay] expected_text
#
# The "request_string" is just send to the co-process while the
# "expected_text" is looked for in the commands output. If the "delay"
# is reached before text is recieved the program will abort with an error.
#
# If the expected text is not found in the "log_file" (polled), the script
# will wait one second, try again, then wait two seconds, then three seconds,
# until either the expected text is found, or it hits a maximum - as defined
# by MAX_WAITS. The delay is optional, and if not given an immediate response
# is expected.
#
# Maximum time for wait is 1+2+3+4+...+N  so the default value will wait
# a maximum of 15 seconds for a response from the script. (Hard coded in
# script)
#
# Example "expect_data" file, to run a telent command to a remote system
#
#   #
#   # shell_expect this_file telnet_log | telnet > telnet_log
#   #
#   S open remote_host 23
#   E5 ogin:
#   S my_username
#   E2 assword:
#   S my_password
#   E5 prompt>
#   S ls /tmp
#   E1 prompt>
#   S cal
#   E1 prompt>
#   S exit
#   E5 logout
#
# WARNING: Using password in a data file like the above is NOT recommended.
#
###
#
# Original technique from the Sun Microsystems' "Explorer" utility.
#
# Script originally written by Steve Parker, and presented in
#   "Simple Expect Replacement"   http://steve-parker.org/sh/expect.shtml
#
# Re-written to be more generic by Anthony Thyssen, June 2011, as part of
#   http://www.ict.griffith.edu.au/anthony/info/shell/co-processes.hints
#
EXPECT_DATA="$1"
LOG_FILE="$2"
MAX_WAITS=5    # poll every 1+2+3+...+N second  5 => 15 sec maximum

while read line; do
  c=`echo "$line" |cut -c1`
  if [ "x$c" == "x#" ]; then
    : comment line -- ignore

  elif [ "x$c" == "xE" ]; then
    expected=`echo "$line" | cut -d" " -f2-`
    delay=`echo "$line" | cut -d" " -f1 | cut -c2-`
    if [ -z "$delay" ]; then
      sleep "$delay"
    fi
    res=1
    i=0
    while [ "$res" -ne "0" ]; do
      tail -1 "$LOG_FILE" 2>/dev/null | grep "$expected" > /dev/null
      res=$?
      sleep $i
      i=`expr $i + 1`
      if [ "$i" -gt "${MAX_WAITS}" ]; then
        echo "ERROR : Timeout waiting for $expected" >> $LOG_FILE
        exit 1
      fi
    done

  elif [ "x$c" == "xS" ]; then
    echo "$line" | cut -d" " -f2-

  else
    echo "ERROR: syntax error in expect data \"$EXPECT_DATA\" >> $LOG_FILE
    exit 10
  fi
done < "$EXPECT_DATA"

