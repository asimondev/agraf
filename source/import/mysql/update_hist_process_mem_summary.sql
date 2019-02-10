select 'Updating hist_process_mem_summary.' as '';
select curtime();

update hist_process_mem_summary
set category = trim(category)
\g

create unique index hist_process_mem_summary_pk on hist_process_mem_summary(
  con_dbid, con_id, instance_number, category, end_interval_time)
\g

create index hist_process_mem_summary_category on 
  hist_process_mem_summary(category)
\g
