select 'Updating hist_seg_stat_obj.' as '';
select curtime();

update hist_seg_stat_obj
set 
  owner = trim(owner),
  object_name = trim(object_name),
  subobject_name = trim(subobject_name),
  object_type = trim(object_type),
  tablespace_name = trim(tablespace_name),
  partition_type = trim(partition_type)
\g

create index hist_seg_stat_obj_idx1 on
  hist_seg_stat_obj(obj_id, dataobj_id, ts_id)
\g

create index hist_seg_stat_obj_idx2 on hist_seg_stat_obj(
  id, con_dbid, con_id)
\g
