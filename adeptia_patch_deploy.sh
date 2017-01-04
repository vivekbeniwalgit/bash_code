#!/bin/bash -x
#adeptia_patch_deploy.sh_v2.0
current_dir=`echo "$0" | rev | cut -d\/ -f2- | rev`
cd $current_dir
. ../properties/adeptia_patch_deploy.env
start_timestamp=`date +"%N"`
        echo $start_timestamp
#======================================================================== fn_patch_deploy ==========================================================================#
fn_patch_deploy() {	
			clean_up() {
                                        ssh $user@$host_name "ls -lrt ls -lrt /tmp;\
								sudo rm -fR /tmp/Migration;\
								sudo rm -f /tmp/$1;\
								ls -lrt /tmp;\
								cat /usr/local/installations/Adeptia/patches/$2/patch_error;\
								sudo rm -f /usr/local/installations/Adeptia/patches/$2/patch_error"
                                        rm -f $working_copy/$1
                        }
			adeptia_patch_to_be_deployed=$1 
			patch_release_to_be_deployed=$2
			patch_dir=`echo $patch_release_to_be_deployed | rev | cut -d"_" -f1-2 | rev`
			svn export $svn_url/$adeptia_patch_to_be_deployed $working_copy/$adeptia_patch_to_be_deployed
                        echo "Copying patch $adeptia_patch_to_be_deployed to $host_name"
                        scp $working_copy/$1 $user@$host_name:/tmp
			
			if [ -d `ssh $user@$host_name "/usr/local/installations/Adeptia/patches/$patch_dir"` ];then
                                ssh $user@$host_name "cd /usr/local/installations/Adeptia/patches/;sudo rm -rf $patch_dir"
                        fi
			
			ssh $user@$host_name "sudo mkdir -p /usr/local/installations/Adeptia/patches/$patch_dir;\
				sudo cp /tmp/$adeptia_patch_to_be_deployed /usr/local/installations/Adeptia/patches/$patch_dir/$adeptia_patch_to_be_deployed;\
				cd /usr/local/installations/Adeptia/patches/$patch_dir/;\
				sudo unzip $adeptia_patch_to_be_deployed;\
				sudo service adeptia stop;\
				sudo chmod 775 -R /usr/local/installations/Adeptia/patches/$patch_dir;\
				cd /usr/local/installations/Adeptia/patches/$patch_dir/;\
				echo "\r" | sudo sh ./Apply-RecoverPatch.sh /usr/local/bin/AdeptiaSuite/AdeptiaSuite-6.0/AdeptiaServer" 
			ssh $user@$host_name "sudo service adeptia start"
			patch_deployed=`ssh $user@$host_name "cat /usr/local/bin/AdeptiaSuite/AdeptiaSuite-6.0/AdeptiaServer/ServerKernel/etc/CVS/Tag"`
			if [ "$current_patch" = "$patch_deployed" ]; then
				ssh $user@$host_name "sudo echo $deploy_patch_id > /usr/local/bin/AdeptiaSuite/AdeptiaSuite-6.0/AdeptiaServer/ServerKernel/etc/CVS/Tag;cat /usr/local/bin/AdeptiaSuite/AdeptiaSuite-6.0/AdeptiaServer/ServerKernel/etc/CVS/Tag"
                	#	echo "Patch Deployment failed on $hostname($carrier_name-$environment)! Please check manually!"
			#	clean_up $adeptia_patch_to_be_deployed $patch_dir
                		
			fi
			clean_up $adeptia_patch_to_be_deployed $patch_dir
}
#======================================================================== fn_patch_deploy ==========================================================================#
echo "Starting the procedure of deploying Adeptia patch $adeptia_patch for $environment, $carrier_name on $host_name"

if [ "$(ssh -o BatchMode=yes -o ConnectTimeout=5 ec2-user@$host_name echo ok 2>&1)" = "ok" ];then
        user=ec2-user

elif [ "$(ssh -o BatchMode=yes -o ConnectTimeout=5 hcen01build@$host_name echo ok 2>&1)" = "ok" ];then
        user=hcen01build

elif [ "$(ssh -o BatchMode=yes -o ConnectTimeout=5 ubuntu@$host_name echo ok 2>&1)" = "ok" ];then
        user=ubuntu

else
        echo "Unable to access $host_name"
        exit 1
fi

current_patch=`ssh $user@$host_name "cat /usr/local/bin/AdeptiaSuite/AdeptiaSuite-6.0/AdeptiaServer/ServerKernel/etc/CVS/Tag"`
echo $current_patch

adeptia_patch_array[0]="AdeptiaSuite_6_0_SP1_28thNov2013.zip"
adeptia_patch_array[1]="AdeptiaSuite_6_0_SP1_19thDec2013.zip"
adeptia_patch_array[2]="AdeptiaSuite_6_0_SP1_20thDec2013.zip"
adeptia_patch_array[3]="AdeptiaSuite_6_0_SP1_20thJan2014.zip"
adeptia_patch_array[4]="AdeptiaSuite_6_0_SP1_22ndJuly_2014.zip"
adeptia_patch_array[5]="AdeptiaSuite_6_0_SP1_1stAug_2014.zip"
adeptia_patch_array[6]="AdeptiaSuite_6_0_SP1_10thOct_2014.zip"
adeptia_patch_array[7]="AdeptiaSuite_6_0_SP1_02Jan_2015.zip"
adeptia_patch_array[8]="AdeptiaSuite_6_0_SP1_29Jan_2015.zip"

patch_id_array[0]="Release_6_0_SP1_07_1_26Nov_2013"
patch_id_array[1]="Release_6_0_SP1_07_2_19Dec_2013"
patch_id_array[2]="Release_6_0_SP1_07_2_20Dec_2013"
patch_id_array[3]="Release_6_0_SP1_07_4_14Jan_2014"
patch_id_array[4]="Release_6_0_SP1_07_4_22July_2014"
patch_id_array[5]="Release_6_0_SP1_07_5_29July_2014"
patch_id_array[6]="Release_6_0_SP1_07_6_19Sep_2014"
patch_id_array[7]="Release_6_0_SP1_07_7_23Dec_2014"
patch_id_array[8]="Release_6_0_SP1_27Jan_2015"

if [[ " ${patch_id_array[*]} " == *" $current_patch "* ]]; then
	echo $current_patch
else
	echo "Unrecognized patch! Please check manually!"
	exit 1
fi
if [[ " ${adeptia_patch_array[*]} " == *" $adeptia_patch "* ]]; then

for (( i=0; i <=$((${#adeptia_patch_array[@]}-1)); i++ ))
do
	if [ "${adeptia_patch_array[$i]}" = "$adeptia_patch" ]; then
		if [ "${patch_id_array[$i]}" = "$current_patch" ]; then
			echo "$adeptia_patch is already deployed on $host_name ($carrier_name-$environment)"
			echo "Deployed patch status on $host_name ($carrier_name-$environment): ** $current_patch **"
		else
			for (( j=0; j <=$((${#patch_id_array[@]}-1)); j++ ))
			do
				if [ "${patch_id_array[$j]}" = "$current_patch" ]; then
					if [ $j -lt $i ]; then
						for (( k=0; k <= $((i-j-1)); k++ )) 
						do
							echo $((j+k+1))
							deploy_patch="${adeptia_patch_array[$((j+k+1))]}"
							deploy_patch_id=${patch_id_array[$((j+k+1))]}
                                                        echo "***************************** Starting deployment of $deploy_patch ****************************"
							fn_patch_deploy $deploy_patch $deploy_patch_id
						done
						break
					elif [ $j -gt $i ]; then
						echo "$host_name ($carrier_name-$environment) is already updated with more recent patch ${adeptia_patch_array[j]}"
						break
					fi	
				fi
			done
		fi
		break
	fi
done

else
	echo "Unknown patch! Please try using "New Patch Deployment Job""
	echo "$host_name ($carrier_name-$environment) Last Deployed Adeptia-Patch status: $current_patch"
fi