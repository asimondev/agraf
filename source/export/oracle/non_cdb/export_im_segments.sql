-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Script to select AWR In-Memory segment statistics into CSV files.
-- Use for Oracle release 19c and later.
-- 

conn / as sysdba

set heading off
@non_cdb/set_echo_verify.sql

define OUT_DIR=&1

spool &OUT_DIR./export_im_segments.log
prompt >>> AGRAF Version 0.1 
prompt >>> Running export_im_segments.sql 

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

@non_cdb/write_dba_hist_im_seg_stat
@non_cdb/write_dba_hist_im_seg_stat_obj

exit
