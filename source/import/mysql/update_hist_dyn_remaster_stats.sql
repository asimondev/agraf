select 'Updating hist_dyn_remaster_stats.' as '';
select curtime();

update hist_dyn_remaster_stats
set remaster_type=trim(remaster_type)
\g

create index hist_dyn_remaster_stats_idx on 
  hist_dyn_remaster_stats(end_interval_time, instance_number, remaster_type)
\g
