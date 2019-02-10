select 'Updating hist_system_event.' as '';
select curtime();
update hist_system_event
set event_name = trim(event_name), wait_class = trim(wait_class)
\g

create index hist_system_event_idx1 on 
  hist_system_event(event_id, instance_number, end_interval_time)
\g

create index hist_system_event_idx2 on 
  hist_system_event(event_id, event_name)
\g
