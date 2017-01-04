#!/bin/bash
. ~postgres/.bash_profile

backup_main_dir=$1
db_name=$2
environment=$3
backup_db_name=$4

logger ()
{
        level=$1
        msg=$2
        echo "######################## [$level] - $msg #########################"
        if [ $# -eq 3 ]; then
                exit 1
        fi
}

BACKUP_DIR="${backup_main_dir}/${environment}_backup"
export BACKUP_DIR
DATE=`date "+%m%d%y_%H%M%S"`
export DATE

cd $BACKUP_DIR
sql_backup_script=`ls postgres_${backup_db_name}_[0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].sql`

if [ ${db_name} = ${backup_db_name} ];then
	dropdb $db_name
	createdb $db_name
	psql -f $BACKUP_DIR/$sql_backup_script
else
	createdb $db_name
	psql -d ${db_name} -f ${sql_backup_script}
fi