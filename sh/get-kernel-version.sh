#!/bin/sh

KERNEL_VERSION=`uname -r| awk  -F '-' 'BEGIN{OFS="."}{ print $1}' |awk  -F '.' 'BEGIN{OFS="."}{ print $1,$2,$3}'`

get_linux_kernel_code()
{
        #expr $(VERSION) \* 65536 + 0$(PATCHLEVEL) \* 256 + 0$(SUBLEVEL));
        VERSION=`echo $1 | awk  -F '.' 'BEGIN{OFS="."}{print $1}'`
        PATCHLEVEL=`echo $1 | awk  -F '.' 'BEGIN{OFS="."}{print $2}'`
        SUBLEVEL=`echo $1 | awk  -F '.' 'BEGIN{OFS="."}{print $3}'`
        #echo $VERSION
        #echo $PATCHLEVEL
        #echo $SUBLEVEL
        KERNEL_CODE=`expr $VERSION \* 65536 + 0$PATCHLEVEL \* 256 + 0$SUBLEVEL`
        return $KERNEL_CODE
}


get_linux_kernel_code $KERNEL_VERSION
echo $KERNEL_VERSION
