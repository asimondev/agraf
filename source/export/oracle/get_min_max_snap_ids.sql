-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- This script gets min and max snapshot IDs from AWR repository.
-- 

conn / as sysdba

define OUT_DIR=&1

spool &OUT_DIR./get_min_max_snap_ids.log
prompt >>> AGRAF Version 0.1 
prompt >>> Running get_min_max_snap_ids.sql.sql

prompt 
prompt Ouput directory : &1
prompt Begin interval  : &2
prompt End interval    : &3
prompt Database ID     : &4
prompt Instance ID     : &5

define db_id=&4
define inst_id=&5
define beg_ivl="&2"
define end_ivl="&3"

set serveroutput on

declare 
  min_snap_id number;
  max_snap_id number;
  inst_id number := &inst_id;
begin
  if inst_id > 0 then
    select max(snap_id) into min_snap_id
    from dba_hist_snapshot
    where dbid = &db_id and instance_number = inst_id and
      begin_interval_time <= to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi');

    select max(snap_id) into max_snap_id
    from dba_hist_snapshot
    where dbid = &db_id and instance_number = inst_id and
      end_interval_time <= to_timestamp('&end_ivl', 'yyyy-mm-dd hh24:mi');
  else
    select max(snap_id) into min_snap_id
    from dba_hist_snapshot
    where dbid = &db_id and
      begin_interval_time <= to_timestamp('&beg_ivl', 'yyyy-mm-dd hh24:mi');

    select max(snap_id) into max_snap_id
    from dba_hist_snapshot
    where dbid = &db_id and
      end_interval_time <= to_timestamp('&end_ivl', 'yyyy-mm-dd hh24:mi');
  end if;

  if min_snap_id is null or max_snap_id is null or 
                              min_snap_id >= max_snap_id then
    dbms_output.put_line('min timestamp: ' || '&beg_ivl' || 
              ', min_snap_id: ' || nvl(to_char(min_snap_id), 'NULL'));
    dbms_output.put_line('max timestamp: ' || '&end_ivl' || 
              ', max_snap_id: ' || nvl(to_char(max_snap_id), 'NULL'));
    raise_application_error(-20001, 
              'Error: the specified time interval is not available.');
  else
    dbms_output.put_line('found min snap_id' || ':' || min_snap_id || ':');
    dbms_output.put_line('found max snap_id' || ':' || max_snap_id || ':');
  end if;
end;
/

spool off
exit
