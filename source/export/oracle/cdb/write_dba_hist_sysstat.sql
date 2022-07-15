-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SYSSTAT into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24
col dif_ivl for a32

spool &OUT_DIR./hist_sysstat.csv

with v as (
select a.snap_id, a.instance_number, b.startup_time,
  a.stat_id, a.stat_name, a.value old_value,
  a.value - lag(a.value)
    over(partition by a.instance_number, b.startup_time, a.stat_id
    order by a.snap_id) dif_value,
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.instance_number, b.startup_time, a.stat_id
    order by a.snap_id) dif_ivl,
  'x;' || nvl(to_char(a.con_dbid), '\N') || ';' ||
  nvl(to_char(a.con_id), '\N') || ';x'
from dba_hist_sysstat a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id and a.stat_name in ('physical reads', 
  'physical writes', 'physical read bytes', 'physical write bytes',
  'redo size', 'redo size for direct writes',
  'redo size for lost write detection',
  'redo writes', 'redo write time',
  'redo log space requests', 'redo log space wait time',
  'redo synch long waits', 'redo synch poll writes',
  'redo synch polls', 'redo synch time', 'redo synch writes',
  'redo synch time (usec)', 'redo synch time overhead (usec)', 
  'redo wastage',
  'DDL statements parallelized', 
  'DML statements parallelized', 'queries parallelized',
  'user commits', 'user calls',
  'session logical reads', 
  'db block gets', 'db block changes',
  'consistent gets', 'consistent changes',
  'sorts (memory)', 'sorts (disk)', 'lob reads', 'lob writes',
  'enqueue deadlocks',
  'temp space allocated (bytes)', 
  'session pga memory',
  'logons cumulative', 'logons current',
  'bytes sent via SQL*Net to client',
  'bytes received via SQL*Net from client',
  'SQL*Net roundtrips to/from client',
  'bytes sent via SQL*Net to dblink',
  'bytes received via SQL*Net from dblink',
  'SQL*Net roundtrips to/from dblink',
  'IM scan CUs memcompress for capacity high',
  'IM scan CUs memcompress for capacity low',
  'IM scan CUs memcompress for dml',
  'IM scan CUs memcompress for query high',
  'IM scan CUs memcompress for query low',
  'IM scan CUs no memcompress',
  'IM scan rows',
  'IM scan rows optimized',
  'IM scan rows projected',
  'IM scan (dynamic) rows',
  'IM scan (dynamic) multi-threaded scans',
  'IM scan (dynamic) tasks processed by thread',
  'IM scan EU rows',
  'IM transactions',
  'IM transactions CUs invalid',
  'IM transactions rows invalidated',
  'IM populate CUs',
  'IM populate EUs',
  'IM repopulate CUs',
  'IM repopulate EUs',
  'IM repopulate (trickle) CUs',
  'IM repopulate (trickle) EUs'
  )
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_value is not null
/

spool off
