WHENEVER SQLERROR EXIT SQL.SQLCODE

set lines 1000
set verify off
set tab off
set serverout on

col v_username new_v v_username nopri
col v_query new_v v_query nopri

select case when version >= 12 then 'C##HASH' else 'HASH' end v_username,
       case when version >= 12 then 'sys.registry$sqlpatch order by ACTION_TIME asc' else 'dual' end v_query
from  (select to_number(substr(version,1,instr(version,'.')-1)) version
         from v$instance);

col v_username clear
col v_query clear

alter session set current_schema=&&v_username.;

select * from sys.registry$history order by ACTION_TIME asc;
select * from &&v_query.;

DEF P_PSU  = '&1'
DEF P_SER  = '&2'
DEF P_VERS = '&3'

DECLARE
  V_ORA_VER_MAJOR NUMBER;
  V_ORA_VERSION   VARCHAR2(20);
BEGIN
  select substr(version,1,instr(version,'.',1,4)-1),substr(version,1,instr(version,'.',1,1)-1) into v_ora_version,v_ora_ver_major from (select '&&P_VERS..0' version from dual);
  IF v_ora_version = '12.1.0.1' THEN
    NULL;
  ELSIF v_ora_version = '12.1.0.2' THEN
    execute immediate 'alter session set exclude_seed_cdb_view=false';
  ELSIF v_ora_ver_major >= 12 THEN
    execute immediate 'alter session set "_exclude_seed_cdb_view"=false';
  END IF;
END;
/

PRO CDB/DBA_SOURCE
@@create_hash_source.sql

PRO CDB/DBA_VIEWS
@@create_hash_view.sql

PRO All others CDB/DBA
@@create_hash_dba_cdb.sql

PRO Non CDB/DBA views or tables
@@create_hash_custom.sql

PRO Database Vault tables
@@create_hash_dv.sql

commit;

alter session set current_schema=&&v_username.;

SELECT SERIES,ORAVERSION,PSU,COUNT(*) FROM T_HASH GROUP BY SERIES,ORAVERSION,PSU ORDER BY 1,2,3;
select SERIES,ORAVERSION,PSU,sum(decode(con_id,1,1,0)) con_id_1, sum(decode(con_id,2,1,0)) con_id_2, sum(decode(con_id,3,1,0)) con_id_3 from t_tab_privs group by SERIES,ORAVERSION,PSU ORDER BY 1,2,3;

exit;
