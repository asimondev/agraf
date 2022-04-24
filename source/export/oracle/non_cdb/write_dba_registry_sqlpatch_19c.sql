-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_REGISTRY_SQLPATH into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./dba_registry_sqlpatch.csv

select install_id, patch_id, patch_uid, patch_type, action, action_time, 
    status, nvl(description, '\N'), flags, 
    source_version, source_build_description, source_build_timestamp,
    target_version, target_build_description, target_build_timestamp
from dba_registry_sqlpatch
order by action_time
/

spool off
