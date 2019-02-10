select 'Updating hist_ash_sessions.' as '';
select curtime();

update hist_ash_sessions
set session_state = trim(session_state),
  event = trim(event),
  sql_id = trim(sql_id),
  sql_opname = trim(sql_opname),
  blocking_status = trim(blocking_status)
\g
  
create index hist_ash_sessions_unique on
  hist_ash_sessions(instance_number, sample_time, con_dbid, con_id)
\g

create index hist_ash_sessions_idx1 on hist_ash_sessions(instance_number, 
  sample_time, session_state, con_dbid, con_id)
\g

create index hist_ash_sessions_idx2 on
  hist_ash_sessions(sample_time)
\g

create index hist_ash_sessions_idx3 on
  hist_ash_sessions(sample_time, sql_id)
\g
