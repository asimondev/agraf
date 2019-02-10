-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select Exadata data from V$CELL into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./vcell.log

select *
from v$cell
order by 2
/

spool off
