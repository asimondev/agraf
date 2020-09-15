drop table if exists graf_statements
\g

create table graf_statements (
  id bigint not null auto_increment,
  sql_id varchar(64) not null,
  con_dbid bigint,
  con_id int,
  sql_text text(32000) not null,
  PRIMARY KEY(id)
)
\g
exit
