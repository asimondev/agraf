select 'Updating hist_pdb_spfile.' as '';
select curtime();

update pdb_spfile
set
  db_uniq_name = trim(db_uniq_name),
  sid = trim(sid),
  name = trim(name),
  value = trim(value)
\g

