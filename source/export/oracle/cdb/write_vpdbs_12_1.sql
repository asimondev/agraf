-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from V$PDBS into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./vpdbs.csv

select con_id, dbid, con_uid, guid, name, open_mode, open_time + 0, total_size,
  '\N;\N;\N;x;\N;\N'
--  application_root, application_pdb, application_seed,
--  'x;' || nvl(to_char(application_root_con_id), '\N') || ';' ||
--  application_root_clone
from v$pdbs
/

spool off
