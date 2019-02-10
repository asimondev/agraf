select 'Updating hist_inst_cache_transfer.' as '';
select curtime();

update hist_inst_cache_transfer
set class=trim(class)
\g

create index hist_inst_cache_transfer_idx on
  hist_inst_cache_transfer(end_interval_time, instance_number, instance, class)
\g
