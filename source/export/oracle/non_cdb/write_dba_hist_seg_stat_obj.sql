-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SEG_STAT_OBJ into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_seg_stat_obj.csv

select a.ts#, a.obj#, a.dataobj#, 
  a.owner, a.object_name, a.subobject_name, a.object_type, 
  a.tablespace_name, a.partition_type,
  'x;\N;\N;x' con_id
from dba_hist_seg_stat_obj a
where a.dbid = &db_id
/

spool off
