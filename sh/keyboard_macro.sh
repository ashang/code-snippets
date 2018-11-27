#!/bin/sh
#
# keyboard_macro [-r] "string"|-
#
# Inject a keyboard macro string into my X windows input stream
# either by reading from standard input, or as a command line argument
#
# OPTIONS
#    -r  add a final newline (or Return key) to the typed string
#
# EXAMPLES
#
# My Email Address
#   keyboard_macro "A.Thyssen@griffith.edu.au"
#
# My Public Web Site
#   keyboard_macro "http://www.ict.griffith.edu.au/anthony/"
#
# Grab my current text selection it clipboard (when Ctrl-C doesn't work)
#   sh -c 'xsel -p | xsel -i -b'
#
# Paste the clipboard into ANY input window (when Ctrl-V doesn't work)
#   sh -c 'xsel -b | keyboard_macro -
#
####
#
# Note: that I sometimes include a 1/2 second delay before the macro is 'typed'
# so that any modifiers the user has used to initiate the keyboard macro has
# been released.  Or I try to 'keyup' those modifier keys.
#
# For Development and other information on injected events into X windows
# See   http://www.ict.griffith.edu.au/anthony/info/X/event_handling.txt
#
# Anthony Thyssen   2012
#

if [ "X$1" = "X-r" ]; then
  shift
  RETURN=true
fi

#method=xte
method=xdotool

case $method in
xte)
  # WARNING:- "xte" version 1.02 truncates to 255 characters.
  # On the other hand "xte" version 1.07 & 1.09 ignores all newlines in the
  # string!  No later version is available as of Sept 2015.
  #
  # The following perl function is a work around, originally provided the
  # by author, and improved oppone my me.  Basically it splits up the input to
  # chunks of 200 characters and handles returns seperatally.
  #
  # But cannot type unicode characters like '§'
  #
  if [ "X$1" = "X-" ]; then
    perl -e '
      # Handle the "str" command of xte,
      # interspersed with the appropriate "key Returns"
      $str=0; $count=0;
      sub str_on()  { if (!$str ) { $str=1; print "str "; $count=0 } }
      sub str_off() { if ( $str ) { $str=0; print "\n"; } }

      print "keyup Super_L\n";      # ensure shift modifier keys up
      print "keyup Control_L\n";
      print "keyup Alt_L\n";
      print "keyup v\n";            # as well as the launch key!
      #
      #print "usleep 500000\n";     # or give time for user to release key

      while ( <> ) {
        for my $char ( split( // ) ) {
          if( $char eq "\n" ) {
            str_off();
            print "key Return\n";
          } else {
            str_on();
            print $char;
            if( $count++ > 200 ) {
              str_off();
      } } } }
      str_off();
      print "key Return\n"   if length("'"$RETURN"'")
      ' - | xte
  else
    # This is for short strings, given on the command line (macros)
    # it should not be used for long strings due to the problems given above.
    xte 'keyup Super_L' 'keyup Control_L' 'keyup Alt_L' 'keyup v' \
        "str $1" \
        ${RETURN:+'key Return'}
  fi
  ;;

xdotool)
  # Use xdotool which has clear modifiers.
  # WARNING before v2015, 'clearmodifiers' restores the modifier afterwards!
  #
  # xdotool can type unicode symbols like '§' which is done by doing
  # keyboard switching.
  #
  # Ensure any and all keys that may have initiated the macro
  # are no longer pressed.
  xdotool keyup Super_L  keyup Control_L   keyup Alt_L   keyup v
  #
  # delay is used to slow input.  EG 10ms between keys
  if [ "X$1" = "X-" ]; then
    xdotool type --clearmodifiers -delay 10 --file -
  else
    echo -n "$1" | xdotool type --clearmodifiers -delay 10 --file -
  fi
  if [ "X$RETURN" != 'X' ]; then
    xdotool key Return
  fi

  # without --clearmodifiers use...
  #xdotool sleep 0.5 type -delay 0 "$1"
  ;;

esac

