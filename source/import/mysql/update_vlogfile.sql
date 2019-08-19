select 'Updating vlogfile.' as '';
select curtime();

update vlogfile
set
  status = trim(status),
  type = trim(type),
  name = trim(name)
\g

