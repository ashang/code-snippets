#!/usr/bin/env bash

count=0

for dir in $(echo $PATH | sed 's/:/ /g')
do
  for item in $(\ls $dir)
  do
    count=$[ $count + 1 ]
  done
  echo "$dir -- $count"
  count=0
done
