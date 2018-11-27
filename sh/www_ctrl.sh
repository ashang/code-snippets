#!/bin/sh
#
# www_ctrl [options] [URL|search_string]
#
#  Popup a mosaic window with the URL given or currently selected text.
#  If a mosaic is not currently running a mosaic will be started
#  automatically.
#
#  OPTIONS:
#     -w     start a new www client window, with the url or search string
#     -i     Remain iconic (noraise)
#     -s     Search for the string, on google search engine
#     -si    Search for an image matching string, on google
#     -wp    Search 'Go' to the matching Wikipedia page
#
# Anthony Thyssen  <A.Thyssen@griffith.edu.au>   25 Jan 1995
#
PROGNAME=`basename $0`

# Pick ONE of the following things
MOSAIC=         # control mosaic?
MOSAIC_CCI=     # use mosaic CCI control?
FIREFOX=true    # attempt to do firefox remote control
MOZILLA=        # attempt to do mozilla remote control
NETSCAPE=       # attempt to do netscape remote control
GOOGLE="http://www.google.com/search?num=100"
G_IMAGE="http://www.google.com/images?num=250&safe=off&imgsafe=off"
G_SEARCH='&hl=en&q='
WIKIPEDIA="http://en.wikipedia.org/wiki/"
WP_MAIN="Main_Page"
WP_SEARCH="Special:Search?submit=go&search="

Usage() {
  echo >&2 "$PROGNAME:" "$@"
  echo >&2 "Usage: $PROGNAME [-i][-w] [URL]"
  exit 10
}

NEW=
loop=true
ns_extra=
ns_opt="-width 810 -height 1000"

while [ "$loop" -a $# -gt 0 ]; do
  case "$1" in
    -i)  shift ;; #ns_opt="$ns_opt -noraise"; shift ;;
    -w)  NEW=true;  ns_extra=",new-window"; shift ;;
    -s)  do_search=true; shift ;;     # Google search for string
    -si) do_image=true; shift ;;      # Google image search
    -wp) do_wp_search=true; shift ;;  # Wikipedia search
    -*)  Usage "Unknown option \"$1\"" ;;
    *)   loop= ;;
  esac
done

# what is the URL to use (get from X selection)
if [ $# -eq 0 ]; then
  url=`{ xselection PRIMARY || xselection CLIPBOARD; } 2>/dev/null | \
          sed 's/^[     ]*//; s/[ >:::]*$//' | tr ' ' '+'`
else
  url="$1"
fi

if [ "$do_search" ]; then
  if [ -z "$url" ]; then
    url="$GOOGLE";
  else
    url="$GOOGLE$G_SEARCH$url"
  fi
elif [ "$do_image" ]; then
  if [ -z "$url" ]; then
    url="$G_IMAGE";
  else
    url="$G_IMAGE$G_SEARCH$url"
  fi
elif [ "$do_wp_search" ]; then
  if [ -z "$url" ]; then
    url="$WIKIPEDIA$WP_MAIN";
  else
    url="$WIKIPEDIA$WP_SEARCH$url"
  fi
fi
#echo "$PROGNAME: DEBUG: Going to $url"

if [ -z "$url" ]; then
  echo >&2 "$PROGNAME: URL not given or found"
  exit 10;
fi

# -----------------------------------------------------
#echo "Jumping to $url  $ns_extra"

if [ "$FIREFOX" ]; then
  # if firefox always open new window, change the advanced preferences
  if [ "$NEW" ]; then
    exec firefox -P default $ns_opt -remote "openURL($url$ns_extra)" &
  else
    exec firefox -P default "$url"  & # open new tab or window
  fi
  exit 0   # Done
fi

if [ "$MOZILLA" ]; then
  ( mozilla $ns_opt -remote "openURL($url$ns_extra)" 2>/dev/null ||
    { mozilla &   sleep 6 &&
      mozilla $ns_opt -remote "openURL($url$ns_extra)"; } ) &
  exit 0   # Done
fi

if [ "$NETSCAPE" ]; then
  # -------- NETSCAPE CONTROL --------
  netscape $ns_opt -remote "openURL($url$ns_extra)" &
  exit 0   # Done
fi


if [ "$MOSAIC_CCI" -a -f $HOME/.mosaiccciport ]; then
  # --------- CCI CONTROL ------------
  host=`sed 's/:.*//' $HOME/.mosaiccciport`
  port=`sed 's/.*://' $HOME/.mosaiccciport`

  output="CURRENT"
  [ $NEW ] && output="NEW"

  send_CCI() {
    # --- CCI command --
    echo "GET URL <$url> OUTPUT $output" |
    # --- telnet connection ---
    # telnet $host $port
    mconnect -p $port $host
  }

  result=`send_CCI 2>&1`

  if  echo $result | grep -s "Connection refused";  then
    echo "CCI FAILURE -- $host:$port..."
    echo "$result"
    rm -f $HOME/.mosaiccciport
  fi
else
  MOSAIC=true
fi

if [ "$MOSAIC" ]; then
  # if mosaic is not running -- start one -- OPTIONAL
  start_mosaic() { /usr/bin/X11/mosaic $url & exit 0; }

  PID=`cat $HOME/.mosaicpid`
  [ $? -ne 0 ] && start_mosaic
  kill -0 $PID 2>/dev/null    # test if pid is running
  [ $? -ne 0 ] && start_mosaic

  cmd=goto
  [ "$NEW" ] && cmd=newwin

  echo "$cmd" > /tmp/Mosaic.$PID
  echo "$url" >> /tmp/Mosaic.$PID
  kill -USR1 $PID
fi

