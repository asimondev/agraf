-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_INSTANCE_RECOVERY into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_instance_recovery.csv

select a.snap_id, a.instance_number, b.startup_time,
  a.RECOVERY_ESTIMATED_IOS, 
  a.ACTUAL_REDO_BLKS,
  a.TARGET_REDO_BLKS,
  nvl(a.LOG_FILE_SIZE_REDO_BLKS, 0),
  nvl(a.LOG_CHKPT_TIMEOUT_REDO_BLKS, 0),
  nvl(a.LOG_CHKPT_INTERVAL_REDO_BLKS, 0),
  nvl(a.TARGET_MTTR, 0), nvl(a.ESTIMATED_MTTR, 0),
  nvl(a.CKPT_BLOCK_WRITES, 0), 
  nvl(a.OPTIMAL_LOGFILE_SIZE, 0),
  nvl(a.ESTD_CLUSTER_AVAILABLE_TIME, 0),
  nvl(a.WRITES_MTTR, 0),
  nvl(a.WRITES_LOGFILE_SIZE, 0),
  nvl(a.WRITES_LOG_CHECKPOINT_SETTINGS, 0),
  nvl(a.WRITES_OTHER_SETTINGS, 0),
  nvl(a.WRITES_AUTOTUNE, 0),
  nvl(a.WRITES_FULL_THREAD_CKPT, 0),
  b.end_interval_time,
 'x;\N;\N;x' con_id
from dba_hist_instance_recovery a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
/

spool off
