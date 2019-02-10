select 'Updating hist_cr_block_server.' as '';
select curtime();

create index hist_cr_block_server_idx on
  hist_cr_block_server(end_interval_time, instance_number)
\g
