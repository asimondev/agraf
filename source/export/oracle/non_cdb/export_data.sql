-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Main script to select AWR data into CSV files.
-- 

conn / as sysdba

set heading off
-- set echo on verify on

define OUT_DIR=&1

spool &OUT_DIR./export_data.log
prompt >>> AGRAF Version 0.1 
prompt >>> Running export_data.sql 

prompt 
prompt Ouput directory : &1
prompt Database ID     : &2
prompt Instance ID     : &3
prompt Begin interval  : &4
prompt End interval    : &5
prompt Begin SNAP_ID   : &6
prompt End SNAP_ID     : &7

alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_tz_format='yyyy-mm-dd hh24:mi:ss tzh:tzm';
alter session set nls_language = 'AMERICAN';
alter session set nls_date_language = 'AMERICAN';
alter session set nls_territory = 'AMERICA';

define db_id=&2
define inst_id="&3"
define beg_ivl="&4"
define end_ivl="&5"
-- define

variable min_snap_id number
variable max_snap_id number
begin
  :min_snap_id := &6;
  :max_snap_id := &7;
end;
/

set termout off

@non_cdb/write_dba_hist_wr_control
@non_cdb/write_dba_hist_snapshot 
@non_cdb/write_dba_hist_sys_time_model
@non_cdb/write_dba_hist_system_event
@non_cdb/write_dba_hist_sysstat
@non_cdb/write_dba_hist_ash_samples
@non_cdb/write_dba_hist_ash_sessions
@non_cdb/write_dba_hist_thread
@non_cdb/write_dba_hist_pgastat
@non_cdb/write_dba_hist_iostat_function
@non_cdb/write_dba_hist_filestatxs
@non_cdb/write_dba_hist_tempstatxs
@non_cdb/write_dba_hist_sqlstat
@non_cdb/write_dba_hist_sqltext
@non_cdb/write_dba_hist_sysmetric_summary
@non_cdb/write_dba_hist_osstat
@non_cdb/write_dba_hist_parameter
@non_cdb/write_vspparameter
@non_cdb/write_dba_hist_cr_block_server
@non_cdb/write_dba_hist_ic_client_stats
@non_cdb/write_dba_hist_interconnect_pings
@non_cdb/write_dba_hist_inst_cache_transfer
@non_cdb/write_dba_hist_undostat
@non_cdb/write_vlog.sql
@non_cdb/write_vstandby_log.sql
@non_cdb/write_vlogfile.sql
@non_cdb/write_dba_hist_instance_recovery.sql
@non_cdb/write_dba_hist_process_mem_summary.sql
@non_cdb/write_dba_hist_log.sql
@non_cdb/write_dba_users.sql

exit
