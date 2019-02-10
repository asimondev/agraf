-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_CURRENT_BLOCK_SERVER into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_current_block_server.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.pin1 old_pin1,
  a.pin1 - lag(a.pin1)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_pin1,
  a.pin10 old_pin10,
  a.pin10 - lag(a.pin10)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_pin10,
  a.pin100 old_pin100,
  a.pin100 - lag(a.pin100)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_pin100,
  a.pin1000 old_pin1000,
  a.pin1000 - lag(a.pin1000)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_pin1000,
  a.pin10000 old_pin10000,
  a.pin10000 - lag(a.pin10000)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_pin10000,
  a.flush1 old_flush1,
  a.flush1 - lag(a.flush1)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_flush1,
  a.flush10 old_flush10,
  a.flush10 - lag(a.flush10)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_flush10,
  a.flush100 old_flush100,
  a.flush100 - lag(a.flush100)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_flush100,
  a.flush1000 old_flush1000,
  a.flush1000 - lag(a.flush1000)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_flush1000,
  a.flush10000 old_flush10000,
  a.flush10000 - lag(a.flush10000)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_flush10000,
  a.write1 old_write1,
  a.write1 - lag(a.write1)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_write1,
  a.write10 old_write10,
  a.write10 - lag(a.write10)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_write10,
  a.write100 old_write100,
  a.write100 - lag(a.write100)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_write100,
  a.write1000 old_write1000,
  a.write1000 - lag(a.write1000)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_write1000,
  a.write10000 old_write10000,
  a.write10000 - lag(a.write10000)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_write10000,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time
    order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_current_block_server a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_pin1 is not null
/

spool off
