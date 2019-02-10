-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SYSTEM_EVENT into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_system_event.csv

with v as (
select a.snap_id, a.dbid, a.instance_number, b.startup_time,
  a.event_id, a.event_name, a.wait_class, a.total_waits old_waits,
  a.time_waited_micro old_waited_micro,
  a.total_waits - lag(a.total_waits)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.event_id
    order by a.snap_id) dif_waits,
  a.time_waited_micro - lag(a.time_waited_micro)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.event_id
    order by a.snap_id) dif_waited_micro,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time, a.event_id
    order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_system_event a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.wait_class <> 'Idle' and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_waits is not null
/

spool off
