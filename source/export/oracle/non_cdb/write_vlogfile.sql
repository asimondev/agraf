-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from V$LOGFILE into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./vlogfile.csv

select group#, status, type, member from v$logfile
/

spool off
