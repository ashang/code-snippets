# make sure [git-]svn answers in english
export LC_ALL="C"

REV_TO=${1:-"HEAD"}
REV_LAST=`cat ChangeLog | head -3 - | tr -d '\r\n' | sed -e 's/.*svn\([0-9]*\).*/\1/'`
REV_FROM=${2:-$(($REV_LAST + 1))}

