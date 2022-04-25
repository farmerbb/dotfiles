#!/bin/bash

mkdir converted

for file in *.zip
do
  PREFIX=$(echo $file | cut -d "_" -f 2 | cut -d "." -f 1 | tr [a-z] [A-Z])
  busybox unzip -p $file $file | busybox unzip -
  for file2 in *.BIN
  do
    mv $file2 converted/${PREFIX}_$file2
  done
done
