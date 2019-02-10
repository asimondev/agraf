-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SQLSTAT into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_sqlstat.csv

with v as (
select a.snap_id, a.dbid, a.instance_number, b.startup_time,
  a.sql_id, a.plan_hash_value,
  a.module, a.action, a.sql_profile, a.parsing_schema_name, 
  a.fetches_total, a.fetches_delta,
  a.fetches_total - lag(a.fetches_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_fetches,
  a.executions_total, a.executions_delta,
  a.executions_total - lag(a.executions_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_executions,
  a.px_servers_execs_total, a.px_servers_execs_delta,
  a.px_servers_execs_total - lag(a.px_servers_execs_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_px_servers_execs,
  a.invalidations_total, a.invalidations_delta,
  a.invalidations_total - lag(a.invalidations_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_invalidations,
  a.parse_calls_total, a.parse_calls_delta,
  a.parse_calls_total - lag(a.parse_calls_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_parse_calls,
  a.disk_reads_total, a.disk_reads_delta,
  a.disk_reads_total - lag(a.disk_reads_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_disk_reads,
  a.buffer_gets_total, a.buffer_gets_delta,
  a.buffer_gets_total - lag(a.buffer_gets_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_buffer_gets,
  a.rows_processed_total, a.rows_processed_delta,
  a.rows_processed_total - lag(a.rows_processed_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_rows_processed,
  a.cpu_time_total, a.cpu_time_delta,
  a.cpu_time_total - lag(a.cpu_time_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_cpu_time,
  a.elapsed_time_total, a.elapsed_time_delta,
  a.elapsed_time_total - lag(a.elapsed_time_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_elapsed_time,
  a.physical_read_bytes_total, a.physical_read_bytes_delta,
  a.physical_read_bytes_total - lag(a.physical_read_bytes_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_physical_read_bytes,
  a.physical_write_bytes_total, a.physical_write_bytes_delta,
  a.physical_write_bytes_total - lag(a.physical_write_bytes_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_physical_write_bytes,
  a.iowait_total, a.iowait_delta,
  a.iowait_total - lag(a.iowait_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_iowait,
  a.clwait_total, a.clwait_delta,
  a.clwait_total - lag(a.clwait_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_clwait,
  a.io_offload_elig_bytes_total, a.io_offload_elig_bytes_delta,
  a.io_offload_elig_bytes_total - lag(a.io_offload_elig_bytes_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_io_offload_elig_bytes,
  a.io_interconnect_bytes_total, a.io_interconnect_bytes_delta,
  a.io_interconnect_bytes_total - lag(a.io_interconnect_bytes_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_io_interconnect_bytes,
  a.physical_read_requests_total, a.physical_read_requests_delta,
  a.physical_read_requests_total - lag(a.physical_read_requests_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_physical_read_requests,
  a.optimized_physical_reads_total, a.optimized_physical_reads_delta,
  a.optimized_physical_reads_total - lag(a.optimized_physical_reads_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) 
    dif_optimized_physical_reads,
  a.cell_uncompressed_bytes_total, a.cell_uncompressed_bytes_delta,
  a.cell_uncompressed_bytes_total - lag(a.cell_uncompressed_bytes_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) 
    dif_cell_uncompressed_bytes,
  a.io_offload_return_bytes_total, 
  case 
    when a.io_offload_return_bytes_delta < 0 then 0
    else a.io_offload_return_bytes_delta
  end as my_io_offl_return_bytes_delta,
  a.io_offload_return_bytes_total - lag(a.io_offload_return_bytes_total)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_io_offload_return_bytes,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time, a.con_dbid,
    a.sql_id, a.plan_hash_value order by a.snap_id) dif_ivl,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_sqlstat a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_executions is not null
/

spool off
