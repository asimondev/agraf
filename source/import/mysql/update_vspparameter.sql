update vspparameter
set
  sid = trim(sid),
  name = trim(name),
  type = trim(type),
  value = trim(value),
  display_value = trim(display_value)
\g

create index vspparameter_idx on vspparameter(name, sid, con_id)
\g

