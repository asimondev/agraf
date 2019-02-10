drop table if exists vspparameter
\g

create table vspparameter (
  sid varchar(80) not null,
  name varchar(80) not null,
  type varchar(11) not null,
  value varchar(255) not null,
  display_value varchar(255) not null,
  ordinal int not null,
  con_id int
)
\g
exit
