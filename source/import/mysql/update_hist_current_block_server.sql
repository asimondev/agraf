select 'Updating hist_current_block_server.' as '';
select curtime();

create index hist_current_block_server_idx on
  hist_current_block_server(end_interval_time, instance_number)
\g
