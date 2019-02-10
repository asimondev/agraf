select 'Updating hist_sysstat.' as '';
select curtime();

update hist_sysstat
set stat_name = trim(stat_name)
\g

create index hist_sysstat_idx1 on hist_sysstat (stat_name, 
  instance_number, end_interval_time, con_dbid, con_id)
\g

