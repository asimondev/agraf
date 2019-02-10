select 'Updating hist_con_sys_time_model.' as '';
select curtime();

update hist_con_sys_time_model
set stat_name = trim(stat_name),
  dummy1 = trim(dummy1), dummy2 = trim(dummy2)
\g

create index hist_con_sys_time_model_idx1 on hist_con_sys_time_model(stat_name,
  instance_number, end_interval_time, con_dbid, con_id)
\g

create index hist_con_sys_time_model_idx2 on hist_con_sys_time_model(
  end_interval_time, instance_number, stat_id, con_dbid, con_id)
\g

