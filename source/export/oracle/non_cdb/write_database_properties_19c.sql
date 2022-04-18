-- Author: Andrej Simon, Oracle ACS Germany
-- 
-- Select data from DATABASE_PROPERTIES into CSV file.
-- 

set pagesi 0 linesi 8256 trimsp on

alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

set feedback off
set colsep ';'
set numwidth 24

spool &OUT_DIR./database_properties.csv

select property_name || ';' || 
  nvl(property_value, '\N') || ';' ||
  replace(nvl(description, '\N'), ';', ',')
from database_properties 
/

spool off
