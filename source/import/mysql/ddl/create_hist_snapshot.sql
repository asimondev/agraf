drop table if exists hist_snapshot
\g

create table hist_snapshot (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  begin_interval_time datetime not null,
  end_interval_time datetime not null,
  snap_level int,
  error_count int,
  snap_flag int,
  con_id int not null,
  primary key (end_interval_time, instance_number)
)
\g
exit
