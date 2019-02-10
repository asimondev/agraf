drop table if exists hist_sysmetric_summary
\g

create table hist_sysmetric_summary (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  begin_time datetime not null,
  end_time datetime not null,
  ivl_size int not null,
  group_id bigint not null,
  metric_id bigint not null,
  metric_name varchar(64) not null,
  metric_unit varchar(64) not null,
  num_interval bigint not null,
  min_value double not null,
  max_value double not null,
  avg_value double not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
