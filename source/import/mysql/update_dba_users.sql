select 'Updating dba_users.' as '';
select curtime();

update dba_users
set username = trim(username)
\g
  
create index dba_users_unique on dba_users(user_id, username, con_id)
\g

create index dba_users_idx1 on dba_users(user_id, con_id)
\g
