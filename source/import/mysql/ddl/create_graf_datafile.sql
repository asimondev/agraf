drop table if exists graf_datafile
\g

create table graf_datafile (
  file_id int not null,
  description varchar(1024),
  con_dbid bigint,
  id int not null auto_increment,
  primary key (id)
)
\g

create unique index graf_datafile_unique on graf_datafile(file_id, con_dbid)
\g
