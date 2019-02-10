-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select Exadata Statistics from DBA_HIST_SYSSTAT into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_exa_sysstat.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.stat_id, a.stat_name, a.value old_value,
  a.value - lag(a.value)
    over(partition by a.instance_number, b.startup_time, a.stat_id
    order by a.snap_id) dif_value,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time, a.stat_id
    order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_sysstat a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id and a.stat_name in (
    'physical read total bytes',
    'physical read total bytes optimized',
    'physical read total IO requests',
    'physical read partial requests',
    'physical read requests optimized',
    'physical write total bytes',
    'physical write total bytes optimized',
    'physical write IO requests',
    'physical write requests optimized',
    'cell flash cache read hits',
    'cell overwrites in flash cache',
    'cell partial writes in flash cache',
    'cell physical IO bytes eligible for predicate offload',
    'cell physical IO bytes saved by storage index',
    'cell physical IO bytes sent directly to DB node to balance CPU',
    'cell physical IO interconnect bytes',
    'cell physical IO interconnect bytes returned by smart scan',
    'cell writes to flash cache'
  )
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_value is not null
/

spool off
