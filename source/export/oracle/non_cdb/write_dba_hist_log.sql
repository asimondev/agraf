-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_LOG into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_log.csv

select a.snap_id, a.instance_number, b.startup_time,
  nvl(a.thread#, 0), a.group#,
  a.bytes, a.members, a.status,
  nvl(to_char(a.first_time, 'yyyy-mm-dd hh24:mi:ss'), '\N'),
  b.end_interval_time,
 'x;\N;\N;x' con_id
from dba_hist_log a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
/

spool off
