-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_ACTIVE_SESS_HISTORY into CSV file.
-- Only the number of sessions and session status are selected.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_ash_samples.csv

with ash as (
  select a.instance_number inst_id, a.sample_time, 
    a.session_state
  from dba_hist_active_sess_history a
  where a.dbid = &db_id and a.instance_number in &inst_id and
    a.sample_time between to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi') and
    to_timestamp('&end_ivl', 'yyyy-mm-dd hh24:mi')
)
select inst_id, 'x;\N;\N;x' con_ids,
  sample_time, 
  session_state, count(*) state_count
from ash
group by inst_id, sample_time, session_state
/

spool off
