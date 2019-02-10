select 'Updating hist_tempstat.' as '';
select curtime();

update hist_tempstat
set file_name = trim(file_name), ts_name=trim(ts_name)
\g

create index hist_tempstat_idx1 on hist_tempstat(file_id, creation_change, 
  instance_number, end_interval_time, con_dbid, con_id)
\g
