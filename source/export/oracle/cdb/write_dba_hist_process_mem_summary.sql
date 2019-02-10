-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_PROCESS_MEM_SUMMARY into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_process_mem_summary.csv

select a.snap_id, a.instance_number, b.startup_time,
  a.category, a.num_processes, nvl(a.non_zero_allocs, 0),
  nvl(a.used_total, 0), nvl(a.allocated_total, 0),
  nvl(a.allocated_max, 0),
  b.end_interval_time,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_process_mem_summary a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
/

spool off
