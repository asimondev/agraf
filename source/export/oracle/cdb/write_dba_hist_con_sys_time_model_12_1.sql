-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from CDB DBA_HIST_CON_SYS_TIME_MODEL into CSV file.
-- 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_con_sys_time_model.csv

select * from dual where 1 = 0
/

spool off
