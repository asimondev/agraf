select 'Updating hist_sqlstat.' as '';
select curtime();

update hist_sqlstat
set module = trim(module), action=trim(action),
  parsing_schema = trim(parsing_schema), sql_profile = trim(sql_profile)
\g

create index hist_sqlstat_idx1 on hist_sqlstat(sql_id, plan_hash_value, 
  instance_number, end_interval_time, con_dbid, con_id)
\g

create index hist_sqlstat_idx2 on hist_sqlstat(sql_id, 
  instance_number, con_dbid, con_id)
\g
