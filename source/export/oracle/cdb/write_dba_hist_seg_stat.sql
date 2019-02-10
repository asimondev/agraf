-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SEG_STAT into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_seg_stat.csv

with v as (
select a.snap_id, a.dbid, a.instance_number, b.startup_time,
  a.ts#, a.obj#, a.dataobj#, 
  a.logical_reads_total, a.logical_reads_delta,
  a.buffer_busy_waits_total, a.buffer_busy_waits_delta,
  a.db_block_changes_total, a.db_block_changes_delta,
  a.physical_reads_total, a.physical_reads_delta,
  a.physical_writes_total, a.physical_writes_delta,
  a.physical_reads_direct_total, a.physical_reads_direct_delta,
  a.physical_writes_direct_total, a.physical_writes_direct_delta,
  a.itl_waits_total, a.itl_waits_delta,
  a.row_lock_waits_total, a.row_lock_waits_delta,
  a.gc_cr_blocks_served_total, a.gc_cr_blocks_served_delta,
  a.gc_cu_blocks_served_total, a.gc_cu_blocks_served_delta,
  a.gc_buffer_busy_total, a.gc_buffer_busy_delta,
  a.gc_cr_blocks_received_total, a.gc_cr_blocks_received_delta,
  a.gc_cu_blocks_received_total, a.gc_cu_blocks_received_delta,
  a.space_used_total, a.space_used_delta,
  a.space_allocated_total, a.space_allocated_delta,
  a.table_scans_total, a.table_scans_delta,
  a.physical_read_requests_total, a.physical_read_requests_delta,
  a.physical_write_requests_total, a.physical_write_requests_delta,
  a.optimized_physical_reads_total, a.optimized_physical_reads_delta,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time, a.con_dbid,
    a.ts#, a.obj#, a.dataobj# order by a.snap_id) dif_ivl,
  'x' || ';' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';' || 'x'
from dba_hist_seg_stat a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_ivl is not null
/

spool off
