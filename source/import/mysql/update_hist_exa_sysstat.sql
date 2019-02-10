select 'Updating hist_exa_sysstat.' as '';
select curtime();

update hist_exa_sysstat
set stat_name = trim(stat_name)
\g

create index hist_exa_sysstat_idx1 on hist_exa_sysstat(stat_name,
  instance_number, end_interval_time, con_dbid, con_id)
\g
