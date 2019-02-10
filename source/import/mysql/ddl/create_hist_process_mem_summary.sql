drop table if exists hist_process_mem_summary
\g

create table hist_process_mem_summary (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  category varchar(15) not null,
  num_processes int not null,
  non_zero_allocs int not null,
  used_total double not null,
  allocated_total double not null,
  allocated_max double not null,
  end_interval_time datetime not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
