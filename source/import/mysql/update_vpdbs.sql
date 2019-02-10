select 'Updating vpdbs.' as '';
select curtime();

update vpdbs
set
  guid = trim(guid),
  name = trim(name),
  open_mode = trim(open_mode),
  app_root = trim(app_root),
  app_pdb = trim(app_pdb),
  app_seed = trim(app_seed),
  app_root_clone = trim(app_root_clone)
\g

create index vpdbs_idx1 on vpdbs(dbid, con_uid, con_id)
\g
