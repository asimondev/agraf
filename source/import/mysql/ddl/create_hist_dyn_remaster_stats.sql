drop table if exists hist_dyn_remaster_stats
\g

create table hist_dyn_remaster_stats (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  remaster_type varchar(11) not null,
  old_remaster_ops double not null,
  dif_remaster_ops double not null,
  old_remaster_time double not null,
  dif_remaster_time double not null,
  old_remastered_objects double not null,
  dif_remastered_objects double not null,
  old_current_objects double not null,
  dif_current_objects double not null,
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
