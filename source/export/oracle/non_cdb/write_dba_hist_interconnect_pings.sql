-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_INTERCONNECT_PINGS into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_interconnect_pings.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.target_instance,
  a.cnt_500b old_cnt_500b,
  a.cnt_500b - lag(a.cnt_500b)
    over(partition by a.instance_number, b.startup_time, a.target_instance
    order by a.snap_id) dif_cnt_500b,
  a.wait_500b old_wait_500b,
  a.wait_500b - lag(a.wait_500b)
    over(partition by a.instance_number, b.startup_time, a.target_instance
    order by a.snap_id) dif_wait_500b,
  a.cnt_8k old_cnt_8k,
  a.cnt_8k - lag(a.cnt_8k)
    over(partition by a.instance_number, b.startup_time, a.target_instance
    order by a.snap_id) dif_cnt_8k,
  a.wait_8k old_wait_8k,
  a.wait_8k - lag(a.wait_8k)
    over(partition by a.instance_number, b.startup_time, a.target_instance
    order by a.snap_id) dif_wait_8k,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time, a.target_instance
    order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_interconnect_pings a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_cnt_500b is not null
/

spool off
