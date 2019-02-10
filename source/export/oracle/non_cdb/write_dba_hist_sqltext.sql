-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SQLTEXT into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_sqltext.csv

select distinct a.sql_id, a.command_type,
  'x;\N;\N;x' con_id
from dba_hist_sqltext a, dba_hist_sqlstat b
where b.dbid = &db_id and b.instance_number in &inst_id and
  b.snap_id between :min_snap_id and :max_snap_id and
  a.sql_id = b.sql_id
/

spool off
