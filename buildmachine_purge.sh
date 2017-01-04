#!/bin/sh
current_dir="/mnt/projects"
cd ${current_dir}

for i in `ls -l | grep ^d | awk '{ print $9 }'`
do
        #cd ${current_dir}/$i/src/
        path=`find ${current_dir}/$i/ -name 'trunk' -type d | grep -v 'trunk/trunk'`
        echo $path
        for j in $path
        do
                if [ -d $j ]; then
                        cd $j
                        rm -Rfv *
        echo "Deleted content at $j"
                fi
        done

        path=`find ${current_dir}/$i/ -name 'branches' -type d`
        echo $path

        for j in $path
        do
                if [ -d $j ]; then
                        cd $j
                        rm -Rfv *
echo "Deleted content at $j"
                fi
        done

        path=`find ${current_dir}/$i/ -name 'tags' -type d`
        echo $path
        for j in $path
        do
                if [ -d $j ]; then
                        cd $j
                        rm -Rfv *
echo "Deleted content at  $j"
                fi
        done
done