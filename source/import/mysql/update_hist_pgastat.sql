select 'Updating hist_pgastat.' as '';
select curtime();

update hist_pgastat
set name = trim(name)
\g
