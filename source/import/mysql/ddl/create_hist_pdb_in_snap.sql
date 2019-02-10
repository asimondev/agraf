drop table if exists hist_pdb_in_snap
\g

create table hist_pdb_in_snap (
  snap_id bigint not null,
  instance_number int not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
