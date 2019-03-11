-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from V$STANDBY_LOG into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./vstandby_log.csv

select thread#, group#, bytes, blocksize, status
from v$standby_log
/

spool off
