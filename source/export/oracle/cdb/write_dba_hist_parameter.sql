-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_PARAMETER into CSV file.
-- 

set pagesi 0 linesi 15000 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep '^'
set numwidth 24

spool &OUT_DIR./hist_parameter.csv

select a.snap_id, a.instance_number, b.startup_time,
  a.parameter_name, a.isdefault, a.ismodified, 
  translate(a.value, chr(10)||chr(13), '  '),
  'x^' || nvl(to_char(a.con_dbid), '\N') || '^' ||
  nvl(to_char(a.con_id), '\N') || '^x',
  b.end_interval_time
from dba_hist_parameter a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id
/

spool off
