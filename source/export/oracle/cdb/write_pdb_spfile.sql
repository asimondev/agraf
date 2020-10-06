-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from PDB_SPFILE$ into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 16384 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./pdb_spfile.csv

select db_uniq_name, pdb_uid, sid, name, value$
from pdb_spfile$
/

spool off
