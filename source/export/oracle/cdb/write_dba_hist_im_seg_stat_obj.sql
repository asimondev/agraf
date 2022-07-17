-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_IM_SEG_STAT_OBJ into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_im_seg_stat_obj.csv

select a.ts#, a.obj#, a.dataobj#, 
  a.owner, a.object_name, a.subobject_name, a.object_type, 
  a.tablespace_name,
  'x' || ';' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';' || 'x'
from dba_hist_im_seg_stat_obj a
where a.dbid = &db_id
/

spool off
