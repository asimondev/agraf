-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from CDB_USERS into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./dba_users.csv

select user_id, username,
  'x;' || nvl(to_char(con_id), '\N') || ';x'
from cdb_users
/

spool off
