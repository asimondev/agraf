-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_IOSTAT_FUNCTION into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_iostat_function.csv

with v as (
select a.snap_id, a.dbid, a.instance_number, b.startup_time,
  a.function_id, a.function_name, 
  a.small_read_megabytes old_small_read_mb,
  a.small_read_megabytes - lag(a.small_read_megabytes)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_small_read_mb,
  a.small_write_megabytes old_small_write_mb,
  a.small_write_megabytes - lag(a.small_write_megabytes)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_small_write_mb,
  a.large_read_megabytes old_large_read_mb,
  a.large_read_megabytes - lag(a.large_read_megabytes)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_large_read_mb,
  a.large_write_megabytes old_large_write_mb,
  a.large_write_megabytes - lag(a.large_write_megabytes)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_large_write_mb,
  a.small_read_reqs old_small_read_rq,
  a.small_read_reqs - lag(a.small_read_reqs)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_small_read_rq,
  a.small_write_reqs old_small_write_rq,
  a.small_write_reqs - lag(a.small_write_reqs)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_small_write_rq,
  a.large_read_reqs old_large_read_rq,
  a.large_read_reqs - lag(a.large_read_reqs)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_large_read_rq,
  a.large_write_reqs old_large_write_rq,
  a.large_write_reqs - lag(a.large_write_reqs)
    over(partition by a.dbid, a.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_large_write_rq,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time,
    a.function_id order by a.snap_id) dif_ivl,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_iostat_function a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_large_read_rq is not null
/

spool off
