drop table if exists graf_snapshot
\g

create table graf_snapshot (
  snap_id bigint not null,
  instance_number int not null,
  snap_time datetime not null,
  snap_sec int not null,
  primary key (snap_time, instance_number)
)
\g
exit
