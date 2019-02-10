drop table if exists vlog
\g

create table vlog (
  thread_nr int not null,
  group_nr int not null,
  bytes bigint not null,
  blocksize int not null,
  status varchar(16) not null,
  members int not null
)
\g
exit
