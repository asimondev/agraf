drop table if exists hist_parameter
\g

create table hist_parameter (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  name varchar(64) not null,
  is_default varchar(9) not null,
  is_modified varchar(10) not null,
  value varchar(512),
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80),
  end_interval_time datetime not null
)
\g
exit
