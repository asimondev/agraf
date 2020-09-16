drop view if exists graf_sqltext
\g

create view graf_sqltext as 
select sql_id, sql_text
from graf_awr_sqls
union
select distinct sql_id, sql_text
from graf_statements
\g

drop view if exists graf_sqltext_source
\g

create view graf_sqltext_source as 
select sql_id, sql_text, 'AWR Reports' as source
from graf_awr_sqls
union
select distinct sql_id, sql_text, 'SQL Text File' as source
from graf_statements
\g
