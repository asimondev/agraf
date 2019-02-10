select 'Updating hist_iostat_function.' as '';
select curtime();

update hist_iostat_function
set function_name = trim(function_name)
\g

create index hist_iostat_function_idx1 on hist_iostat_function(function_name, 
  instance_number, end_interval_time, con_dbid, con_id)
\g
