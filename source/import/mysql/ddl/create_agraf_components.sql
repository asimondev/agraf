drop table if exists agraf_components
\g

create table agraf_components (
  component varchar(64) not null,
  value varchar(64) not null,
  primary key (component)
)
\g

