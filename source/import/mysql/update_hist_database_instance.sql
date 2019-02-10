select 'Updating hist_database_instance.' as '';
select curtime();

update hist_database_instance
set parallel=trim(parallel),
  version = trim(version),
  db_name = trim(db_name),
  instance_name = trim(instance_name),
  host_name = trim(host_name),
  platform_name = trim(platform_name),
  cdb = trim(cdb),
  edition = trim(edition),
  db_unique_name = trim(db_unique_name),
  database_role = trim(database_role)
\g  
