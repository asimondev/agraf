-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_ACTIVE_SESS_HISTORY into CSV file.
-- This script selects session states.
-- 

set pagesi 0 linesi 8192 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_ash_sessions.csv

select to_char(a.instance_number) || ';' || 
  to_char(a.sample_time, 'yyyy-mm-dd hh24:mi:ss')  || ';' ||
  to_char(a.session_id) || ';' || 
  to_char(a.session_serial#) || ';' ||
  a.session_state || ';x;' || 
  nvl(event, '\N') || ';' || 
  nvl(sql_id, '\N') || ';' ||
  nvl(sql_opname, '\N') || ';' ||
  nvl(to_char(user_id), '\N') || ';' || 
  nvl(program, '\N') || ';' || 
  nvl(regexp_replace(machine, '([^[:alnum:]._-])', '*'), '\n') || ';' ||
  nvl('"' || client_id || '"', '\N') || ';' || nvl(module, '\N') || ';' || 
  case 
    when qc_instance_id is null and qc_session_id is null then 0
    else 1
  end || ';' || nvl(pga_allocated, 0) || ';' || 
  nvl(temp_space_allocated, 0) || ';' || 
  blocking_session_status || ';' ||
  nvl(to_char(a.blocking_inst_id), '\N') || ';' ||
  nvl(to_char(a.blocking_session), '\N') || ';' ||
  nvl(to_char(a.blocking_session_serial#), '\N') || 
  ';\N;\N'
from dba_hist_active_sess_history a
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.sample_time between to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi') and
  to_timestamp('&end_ivl', 'yyyy-mm-dd hh24:mi')
/

spool off
