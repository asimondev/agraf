drop table if exists graf_awr_reports
\g

create table graf_awr_reports (
  id mediumint not null auto_increment,
  stmt_id mediumint not null,
  sql_id varchar(64) not null,
  filename varchar(4096) not null,
  PRIMARY KEY(id)
)
\g
exit
