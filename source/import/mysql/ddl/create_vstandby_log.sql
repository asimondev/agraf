drop table if exists vstandby_log
\g

create table vstandby_log (
  thread_nr int not null,
  group_nr int not null,
  bytes bigint not null,
  blocksize int not null,
  status varchar(10) not null, 
  next_time datetime not null
)
\g
exit
