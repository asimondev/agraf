select 'Updating hist_con_system_event.' as '';
select curtime();

update hist_con_system_event
set event_name = trim(event_name), wait_class = trim(wait_class)
\g

create index hist_con_system_event_idx1 on hist_con_system_event(event_name, 
  instance_number, end_interval_time, con_dbid, con_id)
\g

create index hist_con_system_event_idx2 on hist_con_system_event(event_id, 
  con_dbid, con_id, instance_number, end_interval_time)
\g

create index hist_con_system_event_idx3 on 
  hist_con_system_event(snap_id, con_dbid, con_id, instance_number, 
  wait_class, dif_waited_micro)
\g
