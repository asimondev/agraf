select 'Updating hist_osstat.' as '';
select curtime();

update hist_osstat
set stat_name = trim(stat_name)
\g

create index hist_osstat_idx1 on hist_osstat(stat_name,
  instance_number, snap_id, con_dbid, con_id)
\g
