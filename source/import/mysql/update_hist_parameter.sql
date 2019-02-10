select 'Updating hist_parameter.' as '';
select curtime();

update hist_parameter
set
  name = trim(name),
  value = trim(value),
  is_default = trim(is_default),
  is_modified = trim(is_modified)
\g

create index hist_parameter_idx on 
  hist_parameter(name, instance_number, snap_id, con_dbid, con_id)
\g
