select 'Updating hist_ash_samples.' as '';
select curtime();

update hist_ash_samples
set session_state = trim(session_state)
\g

create index hist_ash_samples_idx1 on hist_ash_samples(instance_number, 
  sample_time, session_state, con_dbid, con_id)
\g

create index hist_ash_samples_idx2 on 
  hist_ash_samples(instance_number, session_state, con_dbid, con_id)
\g
