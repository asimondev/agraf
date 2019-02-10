-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_DYN_REMASTER_STATS into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_dyn_remaster_stats.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time, a.remaster_type,
  a.remaster_ops old_remaster_ops,
  a.remaster_ops - lag(a.remaster_ops)
    over(partition by a.instance_number, b.startup_time, a.remaster_type
    order by a.snap_id) dif_remaster_ops,
  a.remaster_time old_remaster_time,
  a.remaster_time - lag(a.remaster_time)
    over(partition by a.instance_number, b.startup_time, a.remaster_type
    order by a.snap_id) dif_remaster_time,
  a.remastered_objects old_remastered_objects,
  a.remastered_objects - lag(a.remastered_objects)
    over(partition by a.instance_number, b.startup_time, a.remaster_type
    order by a.snap_id) dif_remastered_objects,
  a.current_objects old_current_objects,
  a.current_objects - lag(a.current_objects)
    over(partition by a.instance_number, b.startup_time, a.remaster_type
    order by a.snap_id) dif_current_objects,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time, a.remaster_type
    order by a.snap_id) dif_ivl,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_dyn_remaster_stats a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_remaster_ops is not null
/

spool off
