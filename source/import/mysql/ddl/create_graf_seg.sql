drop table if exists graf_seg
\g

create table graf_seg (
  seg_id int not null,
  description varchar(512) not null,
  con_dbid bigint,
  id int not null auto_increment,
  primary key (id)
)
\g

create unique index graf_seg_unique on graf_seg(seg_id, con_dbid)
\g

