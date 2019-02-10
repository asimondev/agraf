drop table if exists hist_con_system_event
\g

create table hist_con_system_event (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  event_id bigint not null, 
  event_name varchar(64) not null,
  wait_class varchar(64) not null,
  old_waits double not null,
  old_waited_micro double not null,
  dif_waits double not null,
  dif_waited_micro double not null,
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
