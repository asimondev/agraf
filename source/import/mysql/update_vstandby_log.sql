select 'Updating vstandby_log.' as '';
select curtime();

update vstandby_log
set
  status = trim(status)
\g

