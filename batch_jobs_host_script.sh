#!/bin/bash
#batch_jobs_host_script.sh
batch_jobs_array=$1

stop_batch_jobs() {
			for i in `echo ${batch_jobs_array}`; do
			
				sudo su tomcat7 << 'EOF'
					ps -ef | grep batch | grep $1
EOF

				
			done
}

start_batch_jobs () {
			for i in `echo ${batch_jobs_array}`; do
				
			done
}

stop_batch_jobs