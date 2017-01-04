#!/bin/bash
series_start=$1
start_new_start=$2
while read line
do
        if [[ $line =~ $series_start ]]; then
                echo $line | sed "s/$series_start/$start_new_start/" >> newfile.txt
                series_start=$(($series_start+1))
                start_new_start=$(($start_new_start+1))
        else
                echo $line >> newfile.txt
        fi
#       series_start=$(($series_start+1))
#       start_new_start=$(($start_new_start+1))
done <tmp.txt
