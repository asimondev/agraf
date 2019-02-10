drop table if exists hist_instance_recovery
\g

create table hist_instance_recovery (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  RECOVERY_ESTIMATED_IOS double not null,
  ACTUAL_REDO_BLKS double not null,
  TARGET_REDO_BLKS double not null,
  LOG_FILE_SIZE_REDO_BLKS double not null,
  LOG_CHKPT_TIMEOUT_REDO_BLKS double not null,
  LOG_CHKPT_INTERVAL_REDO_BLKS double not null,
  TARGET_MTTR double not null,
  ESTIMATED_MTTR double not null,
  CKPT_BLOCK_WRITES double not null,
  OPTIMAL_LOGFILE_SIZE double not null,
  ESTD_CLUSTER_AVAILABLE_TIME double not null,
  WRITES_MTTR double not null,
  WRITES_LOGFILE_SIZE double not null,
  WRITES_LOG_CHECKPOINT_SETTINGS double not null,
  WRITES_OTHER_SETTINGS double not null,
  WRITES_AUTOTUNE double not null,
  WRITES_FULL_THREAD_CKPT double not null,
  end_interval_time datetime not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
