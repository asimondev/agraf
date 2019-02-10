select 'Updating hist_ic_client_stats.' as '';
select curtime();

update hist_ic_client_stats
set name = trim(name)
\g

create index hist_ic_client_stats_idx on 
  hist_ic_client_stats(instance_number, name, end_interval_time)
\g
