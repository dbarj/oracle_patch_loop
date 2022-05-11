WHENEVER SQLERROR EXIT SQL.SQLCODE

set lines 1000
set verify off
set tab off
set serverout on

DEF V_USERNAME = '&1'

-- Convert to uppercase
col v_username new_v v_username nopri
SELECT UPPER('&V_USERNAME.') V_USERNAME FROM DUAL;
col v_username clear

col p_vers new_v p_vers nopri
select substr(version,1,instr(version,'.',1,4)-1) p_vers
from (select version from v$instance);
col p_vers clear

DECLARE
  V_ORA_VER_MAJOR NUMBER;
  V_ORA_VERSION   VARCHAR2(20);
BEGIN
  select substr(version,1,instr(version,'.',1,4)-1),
         substr(version,1,instr(version,'.',1,1)-1)
  into v_ora_version,
       v_ora_ver_major
  from (select '&P_VERS..0' version from dual);
  IF v_ora_version = '12.1.0.1' THEN
    NULL;
  ELSIF v_ora_version = '12.1.0.2' THEN
    execute immediate 'alter session set exclude_seed_cdb_view=false';
  ELSIF v_ora_ver_major >= 12 THEN
    execute immediate 'alter session set "_exclude_seed_cdb_view"=false';
  END IF;
END;
/

PRO CREATE TABLE FOR HASH_LOAD
@@create_hash_load_table.sql

PRO CDB/DBA_SOURCE
@@load_source.sql

PRO CDB/DBA_VIEWS
@@load_view.sql

PRO LOAD HASH/CODE TABLES
@@load_code.sql

PRO Some CDB/DBA Views
@@load_dba_cdb.sql

-- PRO Database Vault tables
-- @@load_database_vault.sql

PRO Some V$ Info
@@load_v_dollar.sql

PRO Non CDB/DBA views or tables
@@load_custom.sql

commit;

PRO Some X$ Info
@@load_x_dollar.sql

commit;

exit;
