-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_IM_SEG_STAT into CSV file.
-- Used for 19c and later.

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_im_seg_stat.csv

with v as (
select a.snap_id, a.dbid, a.instance_number, b.startup_time,
  a.ts#, a.obj#, a.dataobj#,
  a.membytes, 
  a.scans, a.scans_delta, 
  a.db_block_changes, a.db_block_changes_delta,
  a.populate_cus, a.populate_cus_delta,
  a.repopulate_cus, a.repopulate_cus_delta,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time,
    a.ts#, a.obj#, a.dataobj# order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_im_seg_stat a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_ivl is not null
/

spool off
