select 'Updating hist_log.' as '';
select curtime();

update hist_log
set
  status = trim(status)
\g

