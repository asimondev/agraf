drop table if exists graf_min_max_snapshot
\g

create table graf_min_max_snapshot (
  min_snap_id bigint not null,
  max_snap_id bigint not null
)
\g
exit
