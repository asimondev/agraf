drop table if exists graf_ash;
\g

create table graf_ash (
  inst_id int not null,
  sid int not null,
  serial bigint not null,
  description varchar(512) not null,
  con_dbid bigint,
  ash_id bigint,
  id int not null auto_increment,
  primary key (id)
)
\g

