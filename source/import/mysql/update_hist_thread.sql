select 'Updating hist_thread.' as '';
select curtime();

create index hist_thread_idx1 on hist_thread(thread, instance_number, 
  end_interval_time, con_dbid, con_id)
\g

