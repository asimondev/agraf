-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_CR_BLOCK_SERVER into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_cr_block_server.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.cr_requests old_cr_requests,
  a.cr_requests - lag(a.cr_requests)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_cr_requests,
  a.current_requests old_current_requests,
  a.current_requests - lag(a.current_requests)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_current_requests,
  a.data_requests old_data_requests,
  a.data_requests - lag(a.data_requests)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_data_requests,
  a.undo_requests old_undo_requests,
  a.undo_requests - lag(a.undo_requests)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_undo_requests,
  a.tx_requests old_tx_requests,
  a.tx_requests - lag(a.tx_requests)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_tx_requests,
  a.disk_read_results old_disk_read_results,
  a.disk_read_results - lag(a.disk_read_results)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_disk_read_results,
  a.errors old_errors,
  a.errors - lag(a.errors)
    over(partition by a.instance_number, b.startup_time
    order by a.snap_id) dif_errors,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time
    order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_cr_block_server a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_errors is not null
/

spool off
