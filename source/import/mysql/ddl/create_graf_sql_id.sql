drop table if exists graf_sql_id
\g

create table graf_sql_id (
  sql_id varchar(13) not null,
  description varchar(256),
  con_dbid bigint,
  id int not null auto_increment,
  primary key(id)
)
\g

create unique index graf_sql_id_unique on graf_sql_id(sql_id, con_dbid)
\g
