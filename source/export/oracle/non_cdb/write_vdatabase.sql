-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from V$DATABASE into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./vdatabase.csv

select name, db_unique_name, created, log_mode, open_mode, 
protection_mode, protection_level, database_role, 
force_logging, flashback_on
from v$database
/

spool off
