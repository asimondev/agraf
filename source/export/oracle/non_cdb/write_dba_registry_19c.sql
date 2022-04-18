-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_REGISTRY into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./dba_registry.csv

select comp_name, version, version_full, status, modified 
from dba_registry 
order by comp_name, modified
/

spool off
