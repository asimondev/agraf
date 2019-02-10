select 'Updating vlogfile.' as '';
select curtime();

update vlogfile
set
  status = trim(status),
  type = trim(type),
  member = trim(member)
\g

