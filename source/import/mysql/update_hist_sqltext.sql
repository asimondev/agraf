select 'Updating hist_sqltext.' as '';
select curtime();

create index hist_sqltext_idx1 on hist_sqltext(sql_id, con_dbid, con_id)
\g
