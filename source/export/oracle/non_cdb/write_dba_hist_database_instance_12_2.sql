-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_DATABASE_INSTANCE into CSV file.
-- 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_database_instance.csv

with prev_starts as (
  select dbid, instance_number, max(startup_time)
  from dba_hist_database_instance
  where dbid = &db_id and instance_number in &inst_id and
    startup_time < to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi')
  group by dbid, instance_number
)
select dbid, instance_number, startup_time, parallel,
  version, db_name, instance_name, host_name, platform_name,
  cdb, edition, db_unique_name, database_role, cdb_root_dbid
from dba_hist_database_instance
where (dbid, instance_number, startup_time) in (
  select * from prev_starts )
union 
select dbid, instance_number, startup_time, parallel,
  version, db_name, instance_name, host_name, platform_name,
  cdb, edition, db_unique_name, database_role, cdb_root_dbid
from dba_hist_database_instance 
where dbid = &db_id and instance_number in &inst_id and
  startup_time between to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi') and
  to_timestamp('&end_ivl', 'yyyy-mm-dd hh24:mi')
/

spool off
