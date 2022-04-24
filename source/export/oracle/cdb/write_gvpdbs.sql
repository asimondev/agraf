-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from GV$PDBS into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 8192 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./gvpdbs.csv

select inst_id, con_id, dbid, con_uid, guid, name, open_mode, open_time + 0, 
  total_size, creation_time, application_root, application_pdb, 
  application_seed, nvl(to_char(application_root_con_id), '\N'), 
  application_root_clone
from gv$pdbs
/

spool off
