drop table if exists graf_sysmetric
\g

create table graf_sysmetric (
  instance_number int not null,
  metric_date datetime not null,
  metric_name varchar(64) not null,
  min_value double not null,
  max_value double not null,
  avg_value double not null,
  primary key (instance_number, metric_name, metric_date)
)
\g

insert into graf_sysmetric (instance_number,
  metric_date, metric_name, min_value, max_value, avg_value
)
select a.instance_number, 
/*  date_add(a.begin_time, interval 2 second), */
  date_add(a.begin_time, interval a.ivl_size / 100 / 2 second), 
  a.metric_name, a.min_value, a.max_value, a.avg_value
from (
  select b.instance_number, 
    b.begin_time,  b.ivl_size,  
    b.metric_name, b.min_value, b.max_value, b.avg_value
  from hist_sysmetric_summary b
  order by instance_number, metric_name, begin_time
) a
\g

exit
