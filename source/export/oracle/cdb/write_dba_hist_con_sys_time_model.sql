-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from CDB DBA_HIST_CON_SYS_TIME_MODEL into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_con_sys_time_model.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.stat_id, a.stat_name, a.value old_value,
  a.value - lag(a.value)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.stat_id order by a.snap_id) dif_value,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time, a.con_dbid, 
    a.stat_id order by a.snap_id) dif_ivl,
  'x' || ';' || nvl(to_char(a.con_dbid), '\N') || ';' || 
  nvl(to_char(a.con_id), '\N') || ';' || 'x'
from dba_hist_con_sys_time_model a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_value is not null
/

spool off
