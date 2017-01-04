#!/bin/sh

#Combining two files printing lines 1 by 1 alternatively to new file.

count=`wc -l ../properties/disk_usage_pre.txt | tr -dc [:digit:]`
echo $count
while [ $count -gt 0 ]
do
        sed "$count q;d" ../properties/disk_usage_post.txt >> ../properties/disk_usage_cat.txt
        sed "$count q;d" ../properties/disk_usage_pre.txt >> ../properties/disk_usage_cat.txt
        count=`expr $count - 1`
done