drop table if exists hist_pdb_instance
\g

create table hist_pdb_instance (
  instance_number int not null,
  startup_time datetime not null,
  open_time datetime not null,
  open_mode varchar(16),
  pdb_name varchar(128),
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
