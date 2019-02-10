drop table if exists pdb_spfile
\g

create table pdb_spfile (
  db_uniq_name varchar(30),
  pdb_uid bigint,
  sid varchar(80),
  name varchar(80),
  value varchar(4000),
  primary key(name, pdb_uid, sid)
)
\g
exit
