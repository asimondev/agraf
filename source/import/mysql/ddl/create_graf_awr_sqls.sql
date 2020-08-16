drop table if exists graf_awr_sqls
\g

create table graf_awr_sqls (
  id mediumint not null,
  sql_id varchar(64) not null,
  sql_text text(32000) not null,
  PRIMARY KEY(id)
)
\g
exit
