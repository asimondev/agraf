-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SYSMETRIC_SUMMARY into CSV file.
-- 
-- Parameter: 

set pagesi 0 linesi 1024 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./hist_sysmetric_summary.csv

select a.snap_id, a.dbid, a.instance_number,
  a.begin_time, a.end_time, a.intsize, a.group_id, a.metric_id,
  a.metric_name, a.metric_unit, a.num_interval,
  a.minval, a.maxval, a.average,
 'x;\N;\N;x' con_id
from dba_hist_sysmetric_summary a
where a.dbid = &db_id and a.instance_number in &inst_id and
  a.snap_id between :min_snap_id and :max_snap_id and
  a.metric_name in (
    'Active Parallel Sessions', 
    'Active Serial Sessions',
    'Average Active Sessions', 
    'Enqueue Deadlocks Per Sec',
    'Enqueue Waits Per Sec', 
    'Host CPU Utilization (%)', 
    'Buffer Cache Hit Ratio', 
    'Process Limit %',
    'Session Count', 
    'Session Limit %',
    'Total Table Scans Per Sec', 
    'Long Table Scans Per Sec',
    'Total Index Scans Per Sec',
    'Full Index Scans Per Sec',
    'Physical Reads Per Sec', 
    'Physical Reads Direct Per Sec',
    'Average Synchronous Single-Block Read Latency',
    'Queries parallelized Per Sec',
    'DDL statements parallelized Per Sec',
    'DML statements parallelized Per Sec',
    'Total PGA Allocated', 
    'Total PGA Used by SQL Workareas',
    'Temp Space Used', 
    'Network Traffic Volume Per Sec', 
    'Global Cache Blocks Lost', 
    'Global Cache Blocks Corrupted',
    'Global Cache Average CR Get Time', 
    'Global Cache Average Current Get Time',
    'GC CR Block Received Per Second',
    'GC Current Block Received Per Second',
    'Database Time Per Sec', 
    'CPU Usage Per Sec',
    'Database CPU Time Ratio',
    'Database Wait Time Ratio',
    'Cell Physical IO Interconnect Bytes'
  ) 
/

spool off
