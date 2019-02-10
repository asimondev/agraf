select 'Updating hist_pdb_instance.' as '';
select curtime();

update hist_pdb_instance
set open_mode = trim(open_mode),
  pdb_name = trim(pdb_name)
\g

