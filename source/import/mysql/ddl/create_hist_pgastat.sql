drop table if exists hist_pgastat
\g

create table hist_pgastat (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  name varchar(64) not null,
  old_value double not null,
  dif_value double not null,
  end_interval_time datetime not null,
  dif_interval varchar(32) not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80),
  dif_sec double not null,
  primary key (instance_number, name, end_interval_time)
)
\g
exit
