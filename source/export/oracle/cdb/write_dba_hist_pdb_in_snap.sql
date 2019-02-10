-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_PDB_IN_SNAP into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_pdb_in_snap.csv

select snap_id, instance_number,
  'x;' || nvl(to_char(con_dbid), '\N') || ';' ||
  nvl(to_char(con_id), '\N') || ';x'
from dba_hist_pdb_in_snap
/

spool off
