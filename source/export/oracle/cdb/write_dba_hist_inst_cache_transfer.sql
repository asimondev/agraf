-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_INST_CACHE_TRANSFER into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_inst_cache_transfer.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.instance, a.class,
  a.cr_block old_cr_block,
  a.cr_block - lag(a.cr_block)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_cr_block,
  a.cr_busy old_cr_busy,
  a.cr_busy - lag(a.cr_busy)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_cr_busy,
  a.cr_congested old_cr_congested,
  a.cr_congested - lag(a.cr_congested)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_cr_congested,
  a.current_block old_current_block,
  a.current_block - lag(a.current_block)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_current_block,
  a.current_busy old_current_busy,
  a.current_busy - lag(a.current_busy)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_current_busy,
  a.current_congested old_current_congested,
  a.current_congested - lag(a.current_congested)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_current_congested,
  a.lost old_lost,
  a.lost - lag(a.lost)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_lost,
  a.cr_block_time old_cr_block_time,
  a.cr_block_time - lag(a.cr_block_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_cr_block_time,
  a.cr_busy_time old_cr_busy_time,
  a.cr_busy_time - lag(a.cr_busy_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_cr_busy_time,
  a.cr_congested_time old_cr_congested_time,
  a.cr_congested_time - lag(a.cr_congested_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_cr_congested_time,
  a.current_block_time old_current_block_time,
  a.current_block_time - lag(a.current_block_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_current_block_time,
  a.current_busy_time old_current_busy_time,
  a.current_busy_time - lag(a.current_busy_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_current_busy_time,
  a.current_congested_time old_current_congested_time,
  a.current_congested_time - lag(a.current_congested_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_current_congested_time,
  a.lost_time old_lost_time,
  a.lost_time - lag(a.lost_time)
    over(partition by a.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_lost_time,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time, a.instance, a.class
    order by a.snap_id) dif_ivl,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_inst_cache_transfer a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_cr_block is not null
/

spool off
