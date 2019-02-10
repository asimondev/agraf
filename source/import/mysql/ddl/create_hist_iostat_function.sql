drop table if exists hist_iostat_function
\g

create table hist_iostat_function (
  snap_id bigint not null,
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  function_id bigint not null, 
  function_name varchar(64) not null,
  old_small_read_mb double not null,
  dif_small_read_mb double not null,
  old_small_write_mb double not null,
  dif_small_write_mb double not null,
  old_large_read_mb double not null,
  dif_large_read_mb double not null,
  old_large_write_mb double not null,
  dif_large_write_mb double not null,
  old_small_read_rq double not null,
  dif_small_read_rq double not null,
  old_small_write_rq double not null,
  dif_small_write_rq double not null,
  old_large_read_rq double not null,
  dif_large_read_rq double not null,
  old_large_write_rq double not null,
  dif_large_write_rq double not null,
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
