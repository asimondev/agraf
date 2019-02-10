drop table if exists hist_ash_samples
\g

create table hist_ash_samples (
  instance_number int not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80),
  sample_time datetime not null,
  session_state varchar(7) not null,
  state_count int not null
)
\g
exit
