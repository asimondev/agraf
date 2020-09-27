drop table if exists graf_notes;

drop table if exists graf_tags;

create table graf_tags (
  id varchar(32) not null,
  name varchar(64) not null,
  primary key (id)
)
\g

insert into graf_tags values ('no_tag', 'No Tag');
insert into graf_tags values ('parameter', 'Database Parameter');
insert into graf_tags values ('waitevent', 'Wait Event');
insert into graf_tags values ('session', 'Database Session');
insert into graf_tags values ('ash_sample', 'ASH Sample');
insert into graf_tags values ('snap_time', 'AWR Snapshot End Time');
insert into graf_tags values ('pdb_name', 'PDB Name(s)');
insert into graf_tags values ('performance_problem', 'Performance Problem');
insert into graf_tags values ('configuration_problem', 'Configuration Problem');
insert into graf_tags values ('sql_statement', 'SQL Statement');
insert into graf_tags values ('blocking_problem', 'Blocking Issue');

commit;

create table graf_notes (
  time_stamp datetime,
  db_name varchar(128),
  sql_id varchar(13),
  inst_id int,
  sid int,
  serial bigint, 
  tag_id varchar(64),
  tag_value varchar(256),
  pdb_name varchar(128),
  comment text(32000),
  checked varchar(3),
  last_update datetime default current_timestamp on update current_timestamp,
  id int not null auto_increment,
  primary key (id)
)
\g

