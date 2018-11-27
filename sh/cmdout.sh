#!/bin/sh -
#
# cmdout program args...
#
# Wrapper to label the commands output as being from 'stdout' or 'stderr'
# channels And report the final 'exit status' of the comannd.
#
#
#
# Anthony Thyssen     (developed about 1988 or so)
#
[ "X$HTYPE" = 'Xlinux' ] && sed_flag=--unbuffered

echo "CMD:" "$@"
exec 9>&1
( exec 3>&1;
  ( exec 2>&1;
    ( "$@"; echo $? >&3
    ) | sed $sed_flag 's/^/OUT: /; s/	/<TAB>/g' >&9
  ) | sed $sed_flag 's/^/ERR: /; s/	/<TAB>/g' >&9
) | sed $sed_flag 's/^/STAT:/'

exit 0

