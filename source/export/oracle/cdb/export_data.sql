-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Main script to select CDB AWR data into CSV files.
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

@cdb/write_dba_hist_wr_control
@cdb/write_dba_hist_snapshot 
@cdb/write_dba_hist_pdb_in_snap
@cdb/write_dba_hist_pdb_instance
@cdb/write_dba_hist_sys_time_model
@cdb/write_dba_hist_con_sys_time_model
@cdb/write_dba_hist_system_event
@cdb/write_dba_hist_con_system_event
@cdb/write_dba_hist_sysstat
@cdb/write_dba_hist_con_sysstat
@cdb/write_dba_hist_ash_samples
@cdb/write_dba_hist_ash_sessions
@cdb/write_dba_hist_thread
@cdb/write_dba_hist_pgastat
@cdb/write_dba_hist_parameter
@cdb/write_vspparameter
@cdb/write_vpdbs
@cdb/write_pdb_spfile
@cdb/write_dba_hist_iostat_function
@cdb/write_dba_hist_filestatxs
@cdb/write_dba_hist_tempstatxs
@cdb/write_dba_hist_sqlstat
@cdb/write_dba_hist_sqltext
@cdb/write_dba_hist_sysmetric_summary
@cdb/write_dba_hist_osstat
@cdb/write_dba_hist_cr_block_server
@cdb/write_dba_hist_ic_client_stats
@cdb/write_dba_hist_interconnect_pings
@cdb/write_dba_hist_inst_cache_transfer
@cdb/write_dba_hist_undostat
@non_cdb/write_vlog.sql
@non_cdb/write_vstandby_log.sql
@non_cdb/write_vlogfile.sql
@cdb/write_dba_hist_instance_recovery.sql
@cdb/write_dba_hist_process_mem_summary.sql
@non_cdb/write_dba_hist_log.sql
@cdb/write_cdb_users.sql

exit
