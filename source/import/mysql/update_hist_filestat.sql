select 'Updating hist_filestat.' as '';
select curtime();

update hist_filestat
set file_name = trim(file_name), ts_name=trim(ts_name)
\g

create index hist_filestat_idx1 on hist_filestat(file_id, creation_change, 
  instance_number, end_interval_time, con_dbid, con_id)
\g
