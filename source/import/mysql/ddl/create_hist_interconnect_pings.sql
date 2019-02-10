drop table if exists hist_interconnect_pings
\g

create table hist_interconnect_pings (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  target_instance int not null,
  old_cnt_500b double not null,
  dif_cnt_500b double not null,
  old_wait_500b double not null,
  dif_wait_500b double not null,
  old_cnt_8k double not null,
  dif_cnt_8k double not null,
  old_wait_8k double not null,
  dif_wait_8k double not null,
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
