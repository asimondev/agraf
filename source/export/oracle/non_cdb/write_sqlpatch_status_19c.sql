-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBMS_QOPATCH.GET_SQLPATH_STATUS file.
-- 

set pagesi 0 linesi 4096 long 100000 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set serveroutput on size unlimited

spool &OUT_DIR./dbms_sqlpatch_status.csv

exec dbms_qopatch.get_sqlpatch_status;

spool off
