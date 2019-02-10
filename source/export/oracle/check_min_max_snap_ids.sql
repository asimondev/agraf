-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- This script checks specified min and max snapshot IDs from AWR repository.
-- 

conn / as sysdba

define OUT_DIR=&1

spool &OUT_DIR./check_min_max_snap_ids.log
prompt >>> AGRAF Version 0.1 
prompt >>> Running check_min_max_snap_ids.sql

prompt 
prompt Ouput directory   : &1
prompt Begin interval ID : &2
prompt End interval ID   : &3
prompt Database ID       : &4
prompt Instance ID       : &5

define db_id=&4
define inst_id=&5
define beg_ivl_id="&2"
define end_ivl_id="&3"

set serveroutput on

declare 
  min_snap_id number;
  max_snap_id number;
  begin_time timestamp(3);
  end_time   timestamp(3);
  inst_id number := &inst_id;
begin
  if inst_id > 0 then
    select snap_id, min(end_interval_time) 
    into min_snap_id, begin_time
    from dba_hist_snapshot
    where dbid = &db_id and instance_number = inst_id and 
      snap_id = &beg_ivl_id
    group by snap_id;

    select snap_id, min(end_interval_time)
    into max_snap_id, end_time
    from dba_hist_snapshot
    where dbid = &db_id and instance_number = inst_id and
      snap_id = &end_ivl_id
    group by snap_id;
  else
    select snap_id, min(end_interval_time)
    into min_snap_id, begin_time
    from dba_hist_snapshot
    where dbid = &db_id and snap_id = &beg_ivl_id
    group by snap_id;

    select snap_id, min(end_interval_time)
    into max_snap_id, end_time
    from dba_hist_snapshot
    where dbid = &db_id and snap_id = &end_ivl_id
    group by snap_id;
  end if;

  if min_snap_id is null or max_snap_id is null or 
                              min_snap_id >= max_snap_id then
    dbms_output.put_line('begin interval ID: ' || '&beg_ivl_id' || 
              ', min_snap_id: ' || nvl(to_char(min_snap_id), 'NULL'));
    dbms_output.put_line('end interval ID: ' || '&end_ivl_id' || 
              ', max_snap_id: ' || nvl(to_char(max_snap_id), 'NULL'));
    raise_application_error(-20001, 
              'Error: the specified snapshot interval is not available.');
  else
    dbms_output.put_line('found min snap_id' || ':' || min_snap_id || ':');
    dbms_output.put_line('found max snap_id' || ':' || max_snap_id || ':');
    dbms_output.put_line('found begin time' || '#' || 
                          to_char(begin_time, 'yyyy-mm-dd hh24:mi') || '#');
    dbms_output.put_line('found end time' || '#' || 
                          to_char(end_time, 'yyyy-mm-dd hh24:mi') || '#');
  end if;
end;
/

spool off
exit
