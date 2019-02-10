-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_ACTIVE_SESS_HISTORY into CSV file.
-- Only the number of sessions and session status are selected.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_ash_samples.csv

with ash as (
  select a.instance_number inst_id, a.sample_time, a.session_state, 
    a.con_dbid, a.con_id
  from dba_hist_active_sess_history a
  where a.dbid = &db_id and a.instance_number in &inst_id and
    a.sample_time between to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi') and
    to_timestamp('&end_ivl', 'yyyy-mm-dd hh24:mi')
)
select inst_id, 
    'x;' || nvl(to_char(con_dbid), '\N') || ';' ||
    nvl(to_char(con_id), '\N') || ';x',
  sample_time, session_state, count(*) state_count
from ash
group by inst_id, con_dbid, con_id, sample_time, session_state
/

spool off
