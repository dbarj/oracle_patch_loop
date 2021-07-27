WHENEVER SQLERROR EXIT SQL.SQLCODE

col v_username new_v v_username nopri

select case when version >= 12 then 'C##' end || 'HASH' v_username
from  (select to_number(substr(version,1,instr(version,'.')-1)) version
         from v$instance);

col v_username clear

@@createUser.sql &v_username.

conn &v_username./hash;

@@tables_create.sql
