-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from V$SPPARAMETER into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 8192 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./vspparameter.csv

select sid, name, type, 
  translate(value, chr(10)||chr(13), '  '),
  translate(display_value, chr(10)||chr(13), '  '),
  ordinal, 0 con_id
from v$spparameter
where isspecified = 'TRUE'
/

spool off
