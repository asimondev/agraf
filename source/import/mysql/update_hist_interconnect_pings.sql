select 'Updating hist_interconnect_pings.' as '';
select curtime();

create index hist_interconnect_pings_idx on
  hist_interconnect_pings(end_interval_time, instance_number, target_instance)
\g
