drop table if exists hist_seg_stat_obj
\g

create table hist_seg_stat_obj (
  id bigint not null auto_increment,
  ts_id int not null,
  obj_id bigint not null, 
  dataobj_id bigint not null, 
  owner varchar(128),
  object_name varchar(128),
  subobject_name varchar(128),
  object_type varchar(18),
  tablespace_name varchar(30),
  partition_type varchar(8),
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80),
  primary key(id)
)
\g

exit
