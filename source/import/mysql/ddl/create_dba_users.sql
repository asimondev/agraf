drop table if exists dba_users
\g

create table dba_users (
  id bigint not null auto_increment,
  user_id bigint,
  username varchar(128) not null,
  dummy1 varchar(80),
  con_id int,
  dummy2 varchar(80),
  primary key(id)
)
\g
exit
