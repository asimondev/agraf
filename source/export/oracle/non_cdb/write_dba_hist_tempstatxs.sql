-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_TEMPSTATXS into CSV file.
-- 

set pagesi 0 linesi 4096 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_tempstat.csv

with v as (
select a.snap_id, a.dbid, a.instance_number, b.startup_time,
  a.file#, a.creation_change#, a.filename, a.tsname, a.block_size,
  a.phyrds old_phyrds,
  a.phyrds - lag(a.phyrds)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_phyrds,
  a.phywrts old_phywrts,
  a.phywrts - lag(a.phywrts)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_phywrts,
  a.singleblkrds old_singleblkrds,
  a.singleblkrds - lag(a.singleblkrds)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_singleblkrds, 
  a.readtim old_readtim,
  a.readtim - lag(a.readtim)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_readtim, 
  a.writetim old_writetim, 
  a.writetim - lag(a.writetim)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_writetim, 
  a.singleblkrdtim old_singleblkrdtim, 
  a.singleblkrdtim - lag(a.singleblkrdtim)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_singleblkrdtim, 
  a.phyblkrd old_phyblkrd,
  a.phyblkrd - lag(a.phyblkrd)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_phyblkrd,
  a.phyblkwrt old_phyblkwrt,
  a.phyblkwrt - lag(a.phyblkwrt)
    over(partition by a.dbid, a.instance_number, b.startup_time, a.file#, 
    a.creation_change# order by a.snap_id) dif_phyblkwrt, 
  b.end_interval_time,
  b.end_interval_time - lag(b.end_interval_time)
    over (partition by b.dbid, b.instance_number, b.startup_time, a.file#,
    a.creation_change# order by a.snap_id) dif_ivl,
  'x;\N;\N;x' con_id
from dba_hist_tempstatxs a, dba_hist_snapshot b
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.dbid = b.dbid and a.instance_number = b.instance_number and
  a.snap_id = b.snap_id 
)
select v.*, extract(day from v.dif_ivl) * 86400 +
  extract(hour from dif_ivl) * 3600 +
  extract(minute from dif_ivl) * 60 +
  extract(second from dif_ivl) ivl_sec
from v where v.dif_phyrds is not null and
  v.dif_phyrds >= 0 and v.dif_phywrts >= 0
/

spool off
