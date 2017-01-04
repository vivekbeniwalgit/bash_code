[13:02:12] Shakun Singh: #!/bin/bash

. ~postgres/.bash_profile

BACKUP_DIR=/prod-01/postgres/daily-backup
export BACKUP_DIR

DATE=`date "+%m%d%y_%H%M%S"`
export DATE

cd /var/lib/pgsql/backup-daily

pg_dump ss_wig_db >> ss_wig_db_dump.sql
mv ss_wig_db_dump.sql /prod-01/postgres/daily-backup/ss_wig_db_dump_${DATE}.sql

pg_dump ss_wig_db2 >> ss_wig_db2_dump.sql
mv ss_wig_db2_dump.sql /prod-01/postgres/daily-backup/ss_wig_db2_dump_${DATE}.sql

pg_dump wfm_prod_db >> wfm_prod_db_dump.sql
mv wfm_prod_db_dump.sql /prod-01/postgres/daily-backup/wfm_prod_db_dump_${DATE}.sql
[13:02:19] Shakun Singh: -----------------------------------------------------------------------------------------------------
[13:02:33] Shakun Singh: Mongo:

#!/bin/bash

. ~mongo/.bash_profile

BACKUP_DIR=/prod-01/mongo/daily-backups/mongobackup
##BACKUP_DIR=/home/mongo/backup-daily
export BACKUP_DIR

DATE=`date "+%m%d%y_%H%M%S"`
export DATE

cd $BACKUP_DIR

##mongodump --host HCEN02VMA58 --port 27017 --username siteUserAdmin --password ****************  --db ss_wig_db2 --out ${BACKUP_DIR}_${DATE}
mongodump --host HCEN02VMA58 --port 27017 --username ss_wig_db_user --password ************** --db ss_wig_db2 --out ${BACKUP_DIR}_${DATE}
mongodump --host HCEN02VMA58 --port 27017 --username wfm_prod_user --password ****************  --db wfm_prod_db --out ${BACKUP_DIR}_${DATE}

[13:12:15] Shakun Singh: WIG: 10.10.2.89 QA server

[13:12:21] Shakun Singh: DB details
[13:12:27] Shakun Singh: #postgres properties
postgres.url=jdbc:postgresql://10.10.3.61:5432/ahim_qa_db
postgres.database=ahim_qa_db
postgres.userName=ahim_qa_user
postgres.password=welcome123

[13:12:36] Shakun Singh: #mongoDB configuration
wig.db.host=10.10.2.89
wig.db.port=27017
wig.db.name=AHIM_QA_DB
wig.db.username=AHIM_QA_USER
wig.db.password=welcome123

[13:20:50] Shakun Singh: spring_datasource_url_ebill=jdbc:postgresql://billing-dev01.demo.hcentive.com:5432/$ebill_schema
spring_datasource_username=postgres
spring_datasource_password=postgres
host_url=billing-dev01.demo.hcentive.com
mongo_user=wfm_admin
mongo_password=password
mongo_database_name=wfm_billing
db_server=billing-dev01.demo.hcentive.com

[13:21:06] Shakun Singh: DEV server: billing-dev01.demo.hcentive.com
[13:21:15] Vivek Kumar1: ok
[13:21:27] Shakun Singh: ebill_schema=wfmbillingdev15082015
[13:36:05] Vivek Kumar1: -------------------