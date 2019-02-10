drop table if exists hist_database_instance
\g

create table hist_database_instance (
  db_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  parallel varchar(3) not null,
  version varchar(17) not null,
  db_name varchar(9),
  instance_name varchar(16),
  host_name varchar(64),
  platform_name varchar(101),
  cdb varchar(3),
  edition varchar(7),
  db_unique_name varchar(30),
  database_role varchar(30),
  cdb_root_dbid bigint,
  primary key (db_id, instance_number, startup_time)
)
\g
exit
