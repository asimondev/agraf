drop table if exists vpdbs
\g

create table vpdbs (
  con_id int,
  dbid bigint,
  con_uid bigint,
  guid varchar(64),
  name varchar(128),
  open_mode varchar(10),
  open_time datetime,
  total_size double,
  app_root varchar(3),
  app_pdb varchar(3),
  app_seed varchar(3),
  dummy1 varchar(80),
  app_root_con_id int,
  app_root_clone varchar(3)
)
\g
exit
