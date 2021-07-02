-- This code is called just before the expdp. EXPDIR is used by expdp and must exist.
WHENEVER SQLERROR EXIT SQL.SQLCODE

CREATE OR REPLACE DIRECTORY expdir AS '&1';

col v_username new_v v_username nopri

select case when version >= 12 then 'C##' end || 'HASH' v_username
from  (select to_number(substr(version,1,instr(version,'.')-1)) version
         from v$instance);

col v_username clear

GRANT READ,WRITE ON DIRECTORY expdir to &v_username.;

EXIT 0