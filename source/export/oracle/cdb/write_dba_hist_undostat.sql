-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_UNDOSTAT into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 2048 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_undostat.csv

select a.snap_id, a.instance_number, b.startup_time,
  a.begin_time, a.end_time, a.undotsn, a.undoblks,
  a.txncount, a.maxquerylen, a.maxquerysqlid,
  a.maxconcurrency, a.unxpstealcnt, a.unxpblkrelcnt,
  a.unxpblkreucnt, a.expstealcnt, a.expblkrelcnt,
  a.expblkreucnt, a.ssolderrcnt, a.nospaceerrcnt,
  a.activeblks, a.unexpiredblks, a.expiredblks, 
  a.tuned_undoretention,
  b.end_interval_time,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_undostat a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
/

spool off
