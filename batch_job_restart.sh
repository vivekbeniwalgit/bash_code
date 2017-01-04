#!/bin/sh

#batch_job_restart.sh: Restart batch jobs on PHIX CP, PHIX WC, PHIX HAP

        if [ $# -lt 5 ];then
                        echo " \n wrong number of arguments passed, please pass correct arguments, For example: \n"
                        echo " 1. Project: $project\n"
						echo " 2. Environment: $environment\n"
						echo " 3. Host Name: $host_name\n"
						echo " 4. Batch Job(s): $batch_jobs_array\n"
						echo " 5. Jira Ticket Number: $jira_ticket\n"
                        exit 1
        fi
                        current_dir=/var/jenkins/projects/HAP/bin/abs-build-scripts
                        cd $current_dir/bin
                        dos2unix *
                        cd $current_dir/properties
                        . ./batch_job_restart.env

                        start_time="`date '+%m/%d/%Y %H:%M:%S %Z'`"

restart_batch_jobs ()
{

        echo "----------------- Restarting batch jobs ------------------\n\n"

        ssh $user@$host_name"sh -x /tmp/batch_jobs_host_script.sh ${batch_jobs_array}" || logger ERR "Unable to execute host script" 1
        echo "Task completed successfully"
}

copy_host_script ()
{
                        
                        scp $current_dir/bin/batch_jobs_host_script.sh $user@$host_name:/tmp || logger ERR "Unable to copy host script to $host_name" 1

                        restart_batch_jobs

}

logger ()
{
        level=$1
        msg=$2
        echo "######################## [$level] - $msg #########################"
        if [ $# -eq 3 ]; then
                exit 1
        fi
}

#______________________________AUTOMATION PROGRAM START______________________________#

copy_host_script

#_______________________________AUTOMATION PROGRAM END_______________________________#
