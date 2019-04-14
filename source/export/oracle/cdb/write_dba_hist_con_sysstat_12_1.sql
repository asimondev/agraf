-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from CDB DBA_HIST_CON_SYSSTAT into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24
col dif_ivl for a32

spool &OUT_DIR./hist_con_sysstat.csv

select * from dual where 1 = 0
/

spool off
