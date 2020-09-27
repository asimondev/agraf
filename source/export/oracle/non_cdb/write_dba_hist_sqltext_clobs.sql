-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DBA_HIST_SQLTEXT into test file.
-- 
-- Parameter: 

set pagesi 0 linesi 10240 trimsp on
set serveroutput on size unlimited 
set arraysize 1000

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set heading off
set feedback off
set colsep ';'
set numwidth 24

define OUT_FILE=&1

prompt
prompt Ouput file      : &1
prompt Database ID     : &2
prompt Instance ID     : &3
prompt Begin SNAP_ID   : &4
prompt End SNAP_ID     : &5

define db_id=&2
define inst_id="&3"

variable min_snap_id number
variable max_snap_id number
begin
  :min_snap_id := &4;
  :max_snap_id := &5;
end;
/

set termout off
set echo off

spool &OUT_FILE

declare
    cursor c1 is
        select distinct a.sql_id, a.dbid,
            a.con_dbid, a.con_id
        from dba_hist_sqltext a, dba_hist_sqlstat b
        where b.dbid = &db_id and a.dbid = b.dbid and 
            b.instance_number in &inst_id and
            b.snap_id between :min_snap_id and :max_snap_id and
            a.sql_id = b.sql_id;
    l_clob clob;
    l_str varchar2(2048);
    l_amount pls_integer;
    l_offset pls_integer;
    l_cdb varchar2(128);
begin
    select nvl(sys_context('userenv', 'cdb_name'), 'noncdb')
    into l_cdb from dual;
    dbms_output.put_line(l_cdb);    

    for stmt in c1 loop
        dbms_output.put_line(stmt.sql_id || ';' || nvl(stmt.con_dbid, -1) || ';' || nvl(stmt.con_id, -1));

        select sql_text into l_clob from dba_hist_sqltext
        where dbid = stmt.dbid and con_dbid = stmt.con_dbid and 
            sql_id = stmt.sql_id;

        begin
            l_offset := 1;
            l_amount := 2048;
            loop
                dbms_lob.read(l_clob, l_amount, l_offset, l_str);
                dbms_output.put_line(l_str);
                l_offset := l_offset + l_amount;
            end loop;

        exception
            when no_data_found then
                dbms_output.put_line(
'>>>==*******************!!!!!******************************************==<<<');
        end;

    end loop;
end;
/

spool off
