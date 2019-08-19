drop table if exists vlogfile
\g

create table vlogfile (
  group_nr int not null,
  status varchar(7) not null,
  type varchar(7) not null,
  name varchar(1024) not null
)
\g
exit
