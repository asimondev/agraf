drop table if exists hist_sqltext
\g

create table hist_sqltext (
  sql_id varchar(13) not null,
  command_type int,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
