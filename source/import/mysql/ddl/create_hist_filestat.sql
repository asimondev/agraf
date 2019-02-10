drop table if exists hist_filestat
\g

create table hist_filestat (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  file_id bigint not null, 
  creation_change bigint not null, 
  file_name varchar(512) not null,
  ts_name varchar(30) not null,
  block_size int,
  old_preads double not null,
  dif_preads double not null,
  old_pwrites double not null,
  dif_pwrites double not null,
  old_sbreads double not null,
  dif_sbreads double not null,
  old_rtime double not null,
  dif_rtime double not null, 
  old_wtime double not null,
  dif_wtime double not null,
  old_sbrtime double not null,
  dif_sbrtime double not null,
  old_pblk_reads double not null,
  dif_pblk_reads double not null,
  old_pblk_writes double not null,
  dif_pblk_writes double not null,
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
