-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_REGISTRY_HISTORY into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./dba_registry_history.csv

select  action_time, action, namespace, version, id, 
comments, bundle_series
from dba_registry_history
order by action_time
/

spool off
