drop table if exists hist_log
\g

create table hist_log (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  thread_nr int not null,
  group_nr int not null,
  bytes bigint not null,
  members int not null,
  status varchar(16),
  first_time datetime,
  end_interval_time datetime not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
