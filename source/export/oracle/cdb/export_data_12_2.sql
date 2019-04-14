-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Main script to select release 12.2 CDB AWR data into CSV files.
-- 

conn / as sysdba

set heading off
-- set echo on verify on

define OUT_DIR=&1

spool &OUT_DIR./export_data_12_2.log
prompt >>> AGRAF Version 0.1 
prompt >>> Running export_data_12_2.sql 

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

@non_cdb/write_dba_hist_database_instance_12_2
@cdb/write_dba_hist_dyn_remaster_stats_12c
@cdb/write_dba_hist_current_block_server_12_2
@cdb/write_dba_hist_con_sys_time_model
@cdb/write_dba_hist_con_system_event
@cdb/write_dba_hist_con_sysstat
@cdb/write_vpdbs.sql

exit
