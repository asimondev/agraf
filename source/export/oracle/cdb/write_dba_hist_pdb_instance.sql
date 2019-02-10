-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_PDB_INSTANCE into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_pdb_instance.csv

select instance_number, startup_time, open_time, open_mode, pdb_name, 
  'x;' || nvl(to_char(con_dbid), '\N') || ';' ||
  nvl(to_char(con_id), '\N') || ';x'
from dba_hist_pdb_instance
/

spool off
