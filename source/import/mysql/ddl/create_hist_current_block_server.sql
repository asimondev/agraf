drop table if exists hist_current_block_server
\g

create table hist_current_block_server (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  old_pin1 double not null, dif_pin1 double not null,
  old_pin10 double not null, dif_pin10 double not null,
  old_pin100 double not null, dif_pin100 double not null,
  old_pin1000 double not null, dif_pin1000 double not null,
  old_pin10000 double not null, dif_pin10000 double not null,
  old_flush1 double not null, dif_flush1 double not null,
  old_flush10 double not null, dif_flush10 double not null,
  old_flush100 double not null, dif_flush100 double not null,
  old_flush1000 double not null, dif_flush1000 double not null,
  old_flush10000 double not null, dif_flush10000 double not null,
  old_write1 double not null, dif_write1 double not null,
  old_write10 double not null, dif_write10 double not null,
  old_write100 double not null, dif_write100 double not null,
  old_write1000 double not null, dif_write1000 double not null,
  old_write10000 double not null, dif_write10000 double not null,
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
