select 'Updating hist_sysmetric_summary.' as '';
select curtime();

update hist_sysmetric_summary
set metric_name = trim(metric_name), metric_unit=trim(metric_unit)
\g
