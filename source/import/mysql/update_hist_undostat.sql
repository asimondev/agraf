select 'Updating hist_undostat.' as '';
select curtime();

update hist_undostat
set maxquerysqlid = trim(maxquerysqlid)
\g
