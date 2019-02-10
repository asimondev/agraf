select 'Updating vlog.' as '';
select curtime();

update vlog
set
  status = trim(status)
\g

