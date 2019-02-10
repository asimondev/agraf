drop table if exists hist_ic_client_stats
\g

create table hist_ic_client_stats (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  name varchar(9) not null,
  old_bytes_sent double not null,
  dif_bytes_sent double not null,
  old_bytes_received double not null,
  dif_bytes_received double not null,
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
