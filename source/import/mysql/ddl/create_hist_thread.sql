drop table if exists hist_thread
\g

create table hist_thread (
  snap_id bigint not null,
  thread int not null,
  instance_number int not null,
  startup_time datetime not null,
  old_value double not null,
  dif_value double not null,
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
