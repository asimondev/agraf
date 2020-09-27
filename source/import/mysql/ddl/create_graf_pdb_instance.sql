drop view if exists graf_pdb_instance
\g

create view graf_pdb_instance as 
select distinct con_dbid, con_id, instance_number, pdb_name
from hist_pdb_instance
\g
