drop table if exists graf_sqlstat
\g

create table graf_sqlstat (
  snap_id bigint not null,
  instance_number int not null,
  sql_id varchar(13) not null,
  phv_count int not null,
  execs_delta double not null,
  disk_reads_delta double not null,
  buffer_gets_delta double not null,
  rows_delta double not null,
  cpu_time_delta double not null,
  elapsed_time_delta double not null,
  iowait_delta double not null,
  clwait_delta double not null,
  px_servers_delta double not null,
  io_offload_elig_bytes_delta double not null,
  io_interconnect_bytes_delta double not null,
  physical_read_requests_delta double not null,
  optimized_physical_reads_delta double not null,
  cell_uncompressed_bytes_delta double not null,
  io_offload_return_bytes_delta double not null,
  db_time double not null,
  cpu_time double not null,
  system_wait_time double not null,
  cluster_wait_time double not null,
  session_logical_reads double not null,
  physical_reads double not null, 
  end_interval_time datetime not null,
  con_dbid bigint,
  con_id int
)
\g

insert into graf_sqlstat (snap_id, instance_number, 
  sql_id, phv_count, execs_delta,
  disk_reads_delta, buffer_gets_delta, 
  rows_delta, cpu_time_delta, elapsed_time_delta,
  iowait_delta, clwait_delta, px_servers_delta,
  io_offload_elig_bytes_delta,
  io_interconnect_bytes_delta,
  physical_read_requests_delta,
  optimized_physical_reads_delta,
  cell_uncompressed_bytes_delta,
  io_offload_return_bytes_delta,
  db_time, cpu_time, system_wait_time, cluster_wait_time,
  session_logical_reads, physical_reads, end_interval_time,
  con_dbid, con_id
)
select a.snap_id, a.instance_number, 
  a.sql_id, a.phv_count, a.sum_execs,
  a.sum_disk_reads, a.sum_buffer_gets, a.sum_rows,
  a.sum_cpu_time, a.sum_elapsed_time, 
  a.sum_iowait, a.sum_clwait, a.sum_px_servers,
  a.sum_io_offload_elig_bytes, a.sum_io_interconnect_bytes,
  a.sum_physical_read_requests, a.sum_optimized_physical_reads,
  a.sum_cell_uncompressed_bytes, a.sum_io_offload_return_bytes,
  0, 0, 0, 0, 0, 0,
  a.end_interval_time,
  a.con_dbid, a.con_id
from (
  select b.snap_id, b.instance_number, 
    b.sql_id, count(distinct b.plan_hash_value) phv_count, 
    sum(b.execs_delta) sum_execs,
    sum(b.disk_reads_delta) sum_disk_reads,
    sum(b.buffer_gets_delta) sum_buffer_gets,
    sum(b.rows_delta) sum_rows, sum(b.cpu_time_delta) sum_cpu_time,
    sum(b.elapsed_time_delta) sum_elapsed_time,
    sum(b.iowait_delta) sum_iowait, 
    sum(b.clwait_delta) sum_clwait, 
    sum(b.px_execs_delta) sum_px_servers,
    sum(b.io_offload_elig_bytes_delta) sum_io_offload_elig_bytes,
    sum(b.io_interconnect_bytes_delta) sum_io_interconnect_bytes,
    sum(b.physical_read_requests_delta) sum_physical_read_requests,
    sum(b.optimized_physical_reads_delta) sum_optimized_physical_reads,
    sum(b.cell_uncompressed_bytes_delta) sum_cell_uncompressed_bytes,
    sum(b.io_offload_return_bytes_delta) sum_io_offload_return_bytes,
    b.end_interval_time,
    b.con_dbid, b.con_id
  from hist_sqlstat b
  group by b.instance_number, b.con_dbid, b.con_id, b.snap_id, 
    b.end_interval_time, b.sql_id
) a
\g

create index graf_sqlstat_idx1 on graf_sqlstat(sql_id, instance_number, 
  end_interval_time, con_dbid, con_id)
\g

update graf_sqlstat a, hist_con_sys_time_model b
set a.db_time = b.dif_value
where a.instance_number = b.instance_number and a.con_dbid = b.con_dbid and
  a.snap_id = b.snap_id and b.stat_name = 'DB time'
\g

update graf_sqlstat a, hist_con_sys_time_model b
set a.cpu_time = b.dif_value
where a.instance_number = b.instance_number and a.con_dbid = b.con_dbid and
  a.snap_id = b.snap_id and b.stat_name = 'DB CPU'
\g

update graf_sqlstat a
set a.system_wait_time = ifnull((
  select sum(dif_waited_micro)
  from hist_con_system_event b
  where a.instance_number = b.instance_number and a.con_dbid = b.con_dbid and
    a.snap_id = b.snap_id and b.wait_class = 'User I/O'
  ), 0)
\g

update graf_sqlstat a
set a.cluster_wait_time = ifnull((
  select ifnull(sum(dif_waited_micro), 0) cluster_wait_time
  from hist_con_system_event b
  where a.instance_number = b.instance_number and a.con_dbid = b.con_dbid and
    a.snap_id = b.snap_id and b.wait_class = 'Cluster'
  ), 0)
\g

update graf_sqlstat a, hist_con_sysstat b
set a.session_logical_reads = b.dif_value
where a.instance_number = b.instance_number and a.con_dbid = b.con_dbid and
  a.snap_id = b.snap_id and b.stat_name = 'session logical reads'
\g

update graf_sqlstat a, hist_con_sysstat b
set a.physical_reads = b.dif_value
where a.instance_number = b.instance_number and a.con_dbid = b.con_dbid and
  a.snap_id = b.snap_id and b.stat_name = 'physical reads'
\g
