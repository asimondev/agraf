drop table if exists hist_sqlstat
\g

create table hist_sqlstat (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  sql_id varchar(13) not null,
  plan_hash_value bigint not null, 
  module varchar(64),
  action varchar(64),
  sql_profile varchar(64),
  parsing_schema varchar(30),
  fetches_total double not null,
  fetches_delta double not null,
  dif_fetches double not null,
  execs_total double not null,
  execs_delta double not null,
  dif_execs double not null,
  px_execs_total double not null,
  px_execs_delta double not null,
  dif_px_execs double not null,
  invalids_total double not null,
  invalids_delta double not null,
  dif_invalids double not null,
  parses_total double not null,
  parses_delta double not null,
  dif_parses double not null,
  disk_reads_total double not null,
  disk_reads_delta double not null,
  dif_disk_reads double not null,
  buffer_gets_total double not null,
  buffer_gets_delta double not null,
  dif_buffer_gets double not null,
  rows_total double not null,
  rows_delta double not null,
  dif_rows double not null,
  cpu_time_total double not null,
  cpu_time_delta double not null,
  dif_cpu_time double not null,
  elapsed_time_total double not null,
  elapsed_time_delta double not null,
  dif_elapsed_time double not null,
  pread_bytes_total double not null,
  pread_bytes_delta double not null,
  dif_pread_bytes double not null,
  pwrite_bytes_total double not null,
  pwrite_bytes_delta double not null,
  dif_pwrite_bytes double not null,
  iowait_total double not null,
  iowait_delta double not null,
  dif_iowait double not null,
  clwait_total double not null,
  clwait_delta double not null,
  dif_clwait double not null,
  io_offload_elig_bytes_total double not null,
  io_offload_elig_bytes_delta double not null,
  dif_io_offload_elig_bytes double not null,
  io_interconnect_bytes_total double not null,
  io_interconnect_bytes_delta double not null,
  dif_io_interconnect_bytes double not null,
  physical_read_requests_total double not null,
  physical_read_requests_delta double not null,
  dif_physical_read_requests double not null,
  optimized_physical_reads_total double not null,
  optimized_physical_reads_delta double not null,
  dif_optimized_physical_reads double not null,
  cell_uncompressed_bytes_total double not null,
  cell_uncompressed_bytes_delta double not null,
  dif_cell_uncompressed_bytes double not null,
  io_offload_return_bytes_total double not null,
  io_offload_return_bytes_delta double not null,
  dif_io_offload_return_bytes double not null,
  end_interval_time datetime not null,
  dif_interval varchar(32) not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80),
  dif_sec double not null
)
\g
exit
