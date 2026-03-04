#!/bin/csh

set arr = (64 34 25 12 22 11 90)
echo "정렬 전: $arr"

set sorted = (`echo $arr | tr ' ' '\n' | sort -n | tr '\n' ' '`)
echo "정렬 후: $sorted"
