#!/bin/bash
host_name=$1
environment=$2
db_name=$3
is_it_new=$4

user=hcbuild
backup_dir="/home/hcbuild/backup"
current_dir=`readlink -f "$0" | rev | cut -d/ -f2- | rev`

cd $current_dir

logger ()
{
        level=$1
        msg=$2
        echo "######################## [$level] - $msg #########################"
        if [ $# -eq 3 ]; then
                exit 1
        fi
}

start_restore ()
{
	scp pgrestore.sh $user@$db_server:/tmp || logger ERR "!!!Failed to copy file pgdump.sh to $host_name" 1

	ssh $user@$db_server "sudo su postgres << EOF
                                                bash -x /tmp/pgrestore.sh $backup_dir $db_name $environment $backup_db_name
EOF"
}

postgres_url=`ssh hcbuild@$host_name "cat /usr/local/applications/wfm/ws/app-gateway/config/properties/db.properties |grep spring.datasource.url"` || postgres_url=`ssh hcbuild@$host_name "cat /usr/local/applications/wfm/background/billing-notifications-bg/config/properties/db.properties | grep spring.datasource.url"`
backup_db_name=`echo $postgres_url | awk -F [/:] '{print $NF}'`
db_server=`echo $postgres_url | awk -F [/:] '{print $5}'`

if [ ${db_name} = "Existing_DB" ];then
        if [ ${is_it_new} = "NO" ];then
		db_name=${backup_db_name}
                start_restore
	else
		logger ERR "!!! Please provide new db name" 1
	fi
elif [ ${db_name} = ${backup_db_name} ];then
	if [ ${is_it_new} = "NO" ];then
                start_restore
	else
		logger ERR "!!! ${db_name} already exist. Please provide differnt name." 1
        fi
else
	if [ ${is_it_new} = "YES" ];then
                start_restore
	else
		logger ERR "!!! ${db_name} does not  exist." 1
        fi
fi