-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_IC_CLIENT_STATS into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_ic_client_stats.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.name, 
  a.bytes_sent old_bytes_sent,
  a.bytes_sent - lag(a.bytes_sent)
    over(partition by a.instance_number, b.startup_time, a.name
    order by a.snap_id) dif_bytes_sent,
  a.bytes_received old_bytes_received,
  a.bytes_received - lag(a.bytes_received)
    over(partition by a.instance_number, b.startup_time, a.name
    order by a.snap_id) dif_bytes_received,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time, a.name
    order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_ic_client_stats a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_bytes_sent is not null
/

spool off
