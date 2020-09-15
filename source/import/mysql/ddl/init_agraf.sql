source ./create_agraf_components.sql
insert into agraf_components (component, value) values ('cdb', 'no');
insert into agraf_components (component, value) values ('rac', 'no');
commit;
source ./create_graf_ash.sql
source ./create_graf_sql_id.sql
source ./create_graf_awr_sqls.sql
source ./create_graf_statements.sql
source ./create_graf_datafile.sql
source ./create_graf_tempfile.sql
source ./create_graf_seg.sql
source ./create_hist_ash_sessions.sql
