select 'Updating hist_con_sysstat.' as '';
select curtime();

update hist_con_sysstat
set stat_name = trim(stat_name)
\g

create index hist_con_sysstat_idx1 on hist_con_sysstat(stat_name, 
  instance_number, end_interval_time, con_dbid, con_id)
\g

