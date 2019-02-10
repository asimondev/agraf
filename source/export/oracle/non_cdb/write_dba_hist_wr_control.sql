-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_WR_CONTROL into log file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on 
set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_wr_control.log

set pagesi 100 heading on feedback on

select dbid, snap_interval, retention, topnsql, 0 con_id 
from dba_hist_wr_control
/

spool off

set pagesi 0 heading off feedback off
