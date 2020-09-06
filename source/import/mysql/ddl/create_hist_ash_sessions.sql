drop table if exists hist_ash_sessions
\g

create table hist_ash_sessions (
  id bigint not null auto_increment,
  instance_number int not null,
  sample_time datetime not null,
  sid int not null,
  serial bigint not null,
  session_state varchar(7) not null,
  dummy1 varchar(80),
  event varchar(64),
  sql_id varchar(13),
  sql_opname varchar(64),
  user_id int,
  program varchar(64),
  machine varchar(64),
  client_id varchar(64),
  module varchar(64),
  is_px int,
  pga_allocated double not null,
  temp_space_allocated double not null,
  blocking_status varchar(11) not null,
  blocking_inst_id int,
  blocking_sid int,
  blocking_serial bigint,
  action varchar(64),
  con_dbid bigint,
  con_id int,
  primary key(id)
)
\g
exit
