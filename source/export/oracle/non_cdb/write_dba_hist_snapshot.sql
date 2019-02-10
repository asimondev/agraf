-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SNAPSHOT into CSV file.
-- 
-- Parameter: 
--   dbid - Database ID 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_snapshot.csv

select snap_id, dbid, instance_number, startup_time, 
  begin_interval_time, end_interval_time,
  snap_level, error_count, snap_flag, 0 con_id
from dba_hist_snapshot
where dbid = &db_id and instance_number in &inst_id
 and snap_id between :min_snap_id and :max_snap_id
/

spool off

