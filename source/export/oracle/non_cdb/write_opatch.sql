-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBMS_QOPATCH.GET_SQLPATH_STATUS file.
-- 

set pagesi 0 linesi 4096 long 100000 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off

spool &OUT_DIR./opatch_bugs.log
select dbms_qopatch.get_opatch_bugs() from dual;
spool off

spool &OUT_DIR./opatch_list.log
select dbms_qopatch.get_opatch_list() from dual;
spool off

spool &OUT_DIR./opatch_lsinventory.log
select dbms_qopatch.get_opatch_lsinventory() from dual;
spool off
