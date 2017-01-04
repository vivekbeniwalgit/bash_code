current_dir=`echo "$0" | rev | cut -d\/ -f2- | rev`
cd $current_dir
. ../properties/updgrade_patch_array.env

fn_array_list() {
			rm -f $current_dir/release_ls.tmp $current_dir/patch_ls.tmp
			while read  adeptia_patch_ids
        		do
                		echo $adeptia_patch_ids | grep "patch_id_array\[[0-9]\+\]" >> $current_dir/release_ls.tmp
                		echo $adeptia_patch_ids | grep "adeptia_patch_array\[[0-9]\+\]" >> $current_dir/patch_ls.tmp
        		done < $current_dir/$script_file
}
#==================================================================================================================================================#
fn_update_confirm() {
			
			while read  adeptia_patch_ids
                        do
                                echo $adeptia_patch_ids | grep "patch_id_array\[[0-9]\+\]" >> $current_dir/release_ls1.tmp
                                echo $adeptia_patch_ids | grep "adeptia_patch_array\[[0-9]\+\]" >> $current_dir/patch_ls1.tmp
			#	echo $adeptia_patch_ids | grep "adeptia_patch_array\[[0-9]\+\]" | cut -d\" -f2 >> $current_dir/../patch_ls.txt
                        done < $current_dir/$script_file
			rel_1=`diff $current_dir/release_ls.tmp $current_dir/release_ls1.tmp | grep '>' | cut -d\" -f2`
			pat_1=`diff $current_dir/patch_ls.tmp $current_dir/patch_ls1.tmp | grep '>' | cut -d\" -f2`
			rel_2=`sed -n '$p' $current_dir/release_ls1.tmp | cut -d\" -f2`
			pat_2=`sed -n '$p' $current_dir/patch_ls1.tmp | cut -d\" -f2`
			if [[ ( "$new_patch" = "$pat_1" ) && ( "$new_release" = "$rel_1" ) && ( "$new_patch" = "$pat_2" ) && ( "$new_release" = "$rel_2" ) ]]; then
				cat $current_dir/release_ls1.tmp $current_dir/patch_ls1.tmp
				echo "Script updated successfully!"
				cd $current_dir
				svn ci $current_dir/$script_file -m "$new_patch ($new_release) updated"
				sed -i "s/$/,$new_patch/" $current_dir/../properties/patch_ls.txt
				cd $current_dir/../properties
				svn ci $current_dir/../properties/patch_ls.txt -m "$new_patch added"
				cat $current_dir/../properties/patch_ls.txt $current_dir/release_ls1.tmp $current_dir/patch_ls1.tmp
				rm -f $current_dir/release_ls1.tmp $current_dir/patch_ls1.tmp
				fn_tmp_cleanup
			else
				cat $current_dir/release_ls1.tmp $current_dir/patch_ls1.tmp $current_dir/../properties/patch_ls.txt
				echo "*** Error in script ***"
				echo "Reverting changes...."
				cd $current_dir
				svn revert $current_dir/$script_file; if ["$?" != "0" ]; then echo "Unable to revert changes!";fi
				rm -f $current_dir/release_ls1.tmp $current_dir/patch_ls1.tmp
				fn_tmp_cleanup
				exit 1
			fi

}
#==================================================================================================================================================#
fn_tmp_cleanup() {
                  		cat $current_dir/release_ls.tmp $current_dir/patch_ls.tmp
			        rm $current_dir/release_ls.tmp $current_dir/patch_ls.tmp
                                rm -Rf $working_copy
}

#==================================================================================================================================================#
fn_check_duplicacy() {
                                while read  release_ls
                                do
                                        echo $release_ls | grep "$new_release"
                                        if [ "$?" = "0" ]; then 
						echo "Release array already contains $new_release"
						while read  patch_ls
                                		do
                                        		echo $patch_ls | grep "$new_patch"
                                        		if [ "$?" = "0" ]; then echo "Patch array already contains $new_patch";fn_tmp_cleanup;exit 0; fi
                        			done < $current_dir/patch_ls.tmp
					fi
                                done < $current_dir/release_ls.tmp
}

#==================================================================================================================================================#
fn_recency_check() {

fn_date_extraction() {
export release_year=`echo $1 | rev | cut -c1-4 | rev`
release_day_month=`echo $1 | rev | cut -d_ -f2 | rev`
release_month=`echo $release_day_month | tr -d [:digit:] | tr 'a-z' 'A-Z' | cut -c1-3`
export release_day=`echo $release_day_month | tr -dc [:digit:]`
echo $release_name
echo $release_year
echo $release_day_month
echo $release_month
echo $release_day
echo "$release_day $release_month $release_year"

case "$release_month" in
	"JAN") export release_month_num=1;;
	"FEB") export release_month_num=2;;
	"MAR") export release_month_num=3;;
	"APR") export release_month_num=4;;
	"MAY") export release_month_num=5;;
	"JUN") export release_month_num=6;;
	"JUL") export release_month_num=7;;
	"AUG") export release_month_num=8;;
	"SEP") export release_month_num=9;;
	"OCT") export release_month_num=10;;
	"NOV") export release_month_num=11;;
	"DEC") export release_month_num=12;;
	*) echo "Unable to recognize patch release month!";exit 1;;
esac
}
fn_date_extraction $new_release
new_release_year=$release_year
new_release_month=$release_month_num
new_release_day=$release_day

release_name=`sed -n '$p' $current_dir/release_ls.tmp | cut -d\" -f2`	
fn_date_extraction $release_name
if [ "$new_release_year" -eq "$release_year" ]; then
	if [ "$new_release_month" -eq "$release_month_num" ]; then
		if [ "$new_release_day" -gt "$release_day" ]; then
			echo "Ready for Deployment!"
			fn_script_update
		elif [ "$new_release_day" -eq "$release_day" ]; then
			echo "Patch Aready exists!";
			fn_tmp_cleanup
		else
			echo "*****Error: Older Patch*****"
        		echo "Patch is older than $release_name! Please check manually, $new_patch could have been missed!"
			fn_tmp_cleanup;exit 1
		fi

	elif [ "$new_release_month" -gt "$release_month_num" ]; then

			echo "Ready for Deployment!"
			fn_script_update
	else
		echo "*****Error: Older Patch*****"
                echo "Patch is older than $release_name! Please check manually, $new_patch could have been missed!"
                fn_tmp_cleanup;exit 1
	fi
elif [ "$new_release_year" -gt "$release_year" ]; then
	echo "Ready for Deployment!"
	fn_script_update
else
	echo "*****Error: Older Patch*****"
	echo "Patch is older than $release_name! Please check manually, $new_patch could have been missed!"
	fn_tmp_cleanup;exit 1
fi

}
#===============================================================================================================================================================#
fn_script_update() {

total_release=`wc -l < $current_dir/release_ls.tmp`
total_patch=`wc -l < $current_dir/patch_ls.tmp`
re='^[0-9]+$'
if [[ ( "$total_release" = "$total_patch" ) && ( $total_release =~ $re ) ]]; then

	recent_listed_release=`sed -n '$p' $current_dir/release_ls.tmp | cut -d\" -f2`
	recent_listed_patch=`sed -n '$p' $current_dir/patch_ls.tmp | cut -d\" -f2`
	release_array_update="patch_id_array[$total_release]=\"$new_release\""
	patch_array_update="adeptia_patch_array[$total_patch]=\"$new_patch\""
	echo $recent_listed_release
	echo $line_update
	if [ "$new_release" != "$recent_listed_release" ]; then
		if [ "$new_patch" != "$recent_listed_patch" ]; then
			sed -i  "s#${recent_listed_release}\"#${recent_listed_release}\"\n${release_array_update}#" $current_dir/$script_file
			sed -i  "s#${recent_listed_patch}\"#${recent_listed_patch}\"\n${patch_array_update}#" $current_dir/$script_file
			dos2unix $current_dir/$script_file
			echo "Script updated with $new_patch, $new_release"
			fn_update_confirm
		else
			echo "Error with script arrays for patch & release! Patch array already contains $new_patch but Release array does not have $new_release"
			fn_tmp_cleanup
			exit 1
		fi
	else
		if [ "$new_patch" != "$recent_listed_patch" ]; then
			echo "Error with script arrays for patch & release! Release array already contains $new_release but Patch array does not have $new_patch"
			fn_tmp_cleanup
			exit 1
		else
			echo "Script already updated with $new_patch $new_release"
			fn_tmp_cleanup
		fi
	fi
else
	echo "Error with script arrays for patch & release! Patch array has $total_patch elements whereas Release array has $total_release elements"
	cat $current_dir/patch_ls.tmp $current_dir/release_ls.tmp
	fn_tmp_cleanup
	exit 1
fi
}
#===============================================================================================================================================================#
fn_copy_patch() {
	svn info $svn_patch_url/$new_patch | grep Revision
	if [ $? != 0 ]; then
		if [ -e "$temp_dir/$new_patch" ]; then
			rm -rf $working_copy;mkdir -p $working_copy;cd $working_copy
			svn co $svn_patch_url . --depth empty
			if [ -d $working_copy ]; then
				cp $temp_dir/$new_patch $working_copy/$new_patch
				cd $working_copy
				svn add $new_patch
				svn ci $new_patch -m "Adding adeptia patch $new_patch"
			else
				echo "Unable to create directory tree "$working_copy""
				exit 1
			fi
		else
			echo "Please Download $new_patch and copy to $temp_dir"
			exit 1
		fi
	else
		rm -rf $working_copy;mkdir -p $working_copy
		svn  export $svn_patch_url/$new_patch $working_copy/$new_patch
	fi
}
#===============================================================================================================================================================#
echo $svn_patch_url
echo $new_patch
fn_copy_patch
cd $working_copy
unzip $new_patch
new_release=`ls | grep Release | cut -d. -f1`
fn_array_list
fn_check_duplicacy
fn_recency_check