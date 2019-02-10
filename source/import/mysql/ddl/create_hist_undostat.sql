drop table if exists hist_undostat
\g

create table hist_undostat (
  snap_id bigint not null,
  instance_number int not null,
  startup_time datetime not null,
  begin_time datetime not null,
  end_time datetime not null,
  undotsn int not null,
  undoblks double not null,
  txncount bigint not null,
  maxquerylen double not null,
  maxquerysqlid varchar(13),
  maxconcurrency bigint not null,
  unxpstealcnt double not null,
  unxpblkrelcnt double not null,
  unxpblkreucnt double not null,
  expstealcnt double not null,
  expblkrelcnt double not null,
  expblkreucnt double not null,
  ssolderrcnt bigint not null,
  nospaceerrcnt bigint not null,
  activeblks double not null,
  unexpiredblks double not null,
  expiredblks double not null,
  tuned_undoretention double not null,
  end_interval_time datetime not null,
  dummy1 varchar(80),
  con_dbid bigint,
  con_id int,
  dummy2 varchar(80)
)
\g
exit
