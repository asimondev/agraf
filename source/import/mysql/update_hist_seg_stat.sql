select 'Updating hist_seg_stat.' as '';
select curtime();

create index hist_seg_stat_idx1 on
  hist_seg_stat(instance_number, end_interval_time, con_dbid, con_id)
\g

create index hist_seg_stat_idx2 on hist_seg_stat(instance_number, 
  obj_id, dataobj_id, ts_id, end_interval_time, con_dbid, con_id)
\g
