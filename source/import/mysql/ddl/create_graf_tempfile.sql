drop table if exists graf_tempfile
\g

create table graf_tempfile (
  file_id int not null,
  description varchar(1024),
  con_dbid bigint,
  id int not null auto_increment,
  primary key (id)
)
\g

create unique index graf_tempfile_unique on graf_tempfile(file_id, con_dbid)
\g
