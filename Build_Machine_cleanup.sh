#	Crontab job detail
#	30 1 * * * sh -x /var/jenkins/projects/common/bin/abs-build-scripts/bin/purge_buildmachine.sh

#!/bin/sh
current_dir="/mnt/projects"
cd ${current_dir}
du -sh * >> /var/jenkins/projects/common/bin/abs-build-scripts/properties/disk_usage_pre.txt
for i in `ls -l | grep ^d | awk '{ print $9 }'`
do
	#cd ${current_dir}/$i/src/
	path=`find ${current_dir}/$i/ -name 'trunk' -type d | grep -v 'trunk/trunk'`
	echo $path
	for j in $path
	do
		if [ -d $j ]; then
			cd $j
			rm -Rf *
	echo "Deleted content at $j"
		fi
	done
	
	path=`find ${current_dir}/$i/ -name 'branches' -type d`
	echo $path
	
	for j in $path
        do
                if [ -d $j ]; then
                        cd $j
                        rm -Rf *
echo "Deleted content at $j"
                fi
        done
	
	path=`find ${current_dir}/$i/ -name 'tags' -type d`
	echo $path
	for j in $path
        do
                if [ -d $j ]; then
                        cd $j
                        rm -Rf *
echo "Deleted content at  $j"
                fi
        done
done
#================= PRD-PHIX =================#
if [ -d /mnt/projects/PRD-PHIX/artifacts ];then
	cd /mnt/projects/PRD-PHIX/artifacts
	rm -rf *
	mkdir trunk tags branches
fi

if [ -d /mnt/projects/PRD-PHIX/src ];then
	cd /mnt/projects/PRD-PHIX/src
	rm -rf *
        mkdir trunk tags branches db
fi

if  [ -d /mnt/projects/PRD-PHIX ];then
	cd /mnt/projects/PRD-PHIX
	for k in `ls | grep -v [a-zA-Z]`
	do
        	rm -rf $k
	done
fi
#================= WFM-Product =================#
if  [ -d /mnt/projects/WFM-Product  ];then
        cd /mnt/projects/WFM-Product
        for k in `ls | grep -v [a-zA-Z]`
        do
                rm -rf $k
        done
        rm -rf /mnt/projects/WFM-Product/ebill_2_0_artifacts/temp
        mkdir -p /mnt/projects/WFM-Product/ebill_2_0_artifacts/temp
        mkdir -p /mnt/projects/WFM-Product/ebill_2_0_artifacts/branches /mnt/projects/WFM-Product/ebill_2_0_artifacts/tags /mnt/projects/WFM-Product/ebill_2_0_artifacts/trunk
fi
if [ -d /mnt/projects/WFM-Product/src ];then
        cd /mnt/projects/WFM-Product/src
        for k in `ls | grep -v [a-zA-Z]`
        do
                rm -rf $k
        done
fi
#================= Shared_Services =================#
if  [ -d /mnt/projects/Shared_Services ];then
        cd /mnt/projects/Shared_Services
        for k in `ls | grep -v [a-zA-Z]`
        do
                rm -rf $k
        done
fi
#================= Jasper-reports =================#
if [ -d /mnt/projects/JasperReport/WD ];then
	cd /mnt/projects/JasperReport/WD
	for k in `ls | grep -v [a-zA-Z]`
        do
                rm -rf $k
        done
fi
#================= TESTAUTOMATION =================#
if [ -d /mnt/projects/TESTAUTOMATION/src ];then
	cd /mnt/projects/TESTAUTOMATION/src
	for k in `ls | grep -v [a-zA-Z]`
        do
                rm -rf $k
        done
fi

cd ${current_dir}
du -sh * >> /var/jenkins/projects/common/bin/abs-build-scripts/properties/disk_usage_post.txt