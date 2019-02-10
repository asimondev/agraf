select 'Updating hist_sys_time_model.' as '';
select curtime();
update hist_sys_time_model
set stat_name = trim(stat_name)
\g

create index hist_sys_time_model_idx1 on 
  hist_sys_time_model(end_interval_time, instance_number, stat_id)
\g

create index hist_sys_time_model_idx2 on 
  hist_sys_time_model(stat_id, stat_name)
\g
