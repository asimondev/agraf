drop table if exists hist_cr_block_server
\g

create table hist_cr_block_server (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  old_cr_requests double not null,
  dif_cr_requests double not null,
  old_current_requests double not null,
  dif_current_requests double not null,
  old_data_requests double not null,
  dif_data_requests double not null,
  old_undo_requests double not null,
  dif_undo_requests double not null,
  old_tx_requests double not null,
  dif_tx_requests double not null,
  old_disk_read_results double not null,
  dif_disk_read_results double not null,
  old_errors double not null,
  dif_errors double not null,
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
