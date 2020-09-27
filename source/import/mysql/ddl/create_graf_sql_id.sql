drop table if exists graf_sql_id
\g

create table graf_sql_id (
  sql_id varchar(13) not null,
  description varchar(256),
  comment varchar(4096),
  con_dbid bigint,
  last_update datetime default current_timestamp on update current_timestamp,
  id int not null auto_increment,
  primary key(id)
)
\g
