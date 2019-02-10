drop table if exists hist_con_sysstat
\g

create table hist_con_sysstat (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  stat_id bigint not null, 
  stat_name varchar(64) not null,
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
