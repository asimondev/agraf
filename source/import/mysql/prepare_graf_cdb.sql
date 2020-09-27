select 'Creating graf_min_max_snapshot.' as '';
select curtime();
source ./ddl/create_graf_min_max_snapshot.sql
source ./ddl/create_graf_snapshot.sql

insert into graf_min_max_snapshot
select min(snap_id), max(snap_id)
from hist_snapshot
\g

select 'Creating graf_sqlstat.' as '';
select curtime();
source ./ddl/create_graf_sql_id.sql
source ./ddl/create_graf_sqlstat_cdb.sql

select 'Creating graf_sysmetric.' as '';
select curtime();
source ./ddl/create_graf_sysmetric.sql

select 'Creating graf_seg.' as '';
select curtime();
source ./ddl/create_graf_seg.sql

select 'Creating graf_datafile.' as '';
select curtime();
source ./ddl/create_graf_datafile.sql

select 'Creating graf_tempfile.' as '';
select curtime();
source ./ddl/create_graf_tempfile.sql

select 'Creating graf_ash.' as '';
select curtime();
source ./ddl/create_graf_ash.sql
create unique index graf_ash_unique on graf_ash(
  inst_id, sid, serial, con_dbid)
\g

select 'Adding index on hist_ash_sessions.' as '';
select curtime();
create index hist_ash_sessions_time_sql_ses on
  hist_ash_sessions(sample_time, sql_id, con_dbid, instance_number, sid, serial)
\g

select 'Adding AWR SQLs tables.' as '';
source ./ddl/create_graf_awr_sqls.sql
source ./ddl/create_graf_awr_reports.sql

select 'Adding SQL statements table.' as '';
source ./ddl/create_graf_statements.sql

select 'Adding index on graf_sql_id.' as '';
create unique index graf_sql_id_unique on graf_sql_id(sql_id,con_dbid)
\g

select 'Adding SQL text views.' as '';
source ./ddl/create_graf_sqltext_views.sql

select 'Adding CDB index on hist_sqlstat.' as '';
create index hist_sqlstat10 on hist_sqlstat(con_dbid, 
  con_id, instance_number, end_interval_time)
\g

select 'Adding CDB indexes on hist_pdb_instance.' as '';
create index hist_pdb_instance10 on hist_pdb_instance(con_dbid,
  con_id, instance_number)
\g
create index hist_pdb_instance11 on hist_pdb_instance(con_dbid,
  con_id, instance_number, pdb_name)
\g

select 'Adding graf_pdb_instance view.' as '';
source ./ddl/create_graf_pdb_instance.sql

