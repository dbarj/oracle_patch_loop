WHENEVER SQLERROR EXIT SQL.SQLCODE

set lines 1000
set verify off
set tab off
set serverout on

DEF V_USERNAME = '&1'
DEF V_DIRECTORY = '&2'

-- Convert to uppercase
col v_username new_v v_username nopri
col v_directory new_v v_directory nopri
SELECT UPPER('&V_USERNAME.') V_USERNAME, UPPER('&V_DIRECTORY.') V_DIRECTORY FROM DUAL;
col v_username clear
col v_directory clear

col p_vers_4d new_v p_vers_4d nopri
col p_vers_1d new_v p_vers_1d nopri
select substr(version,1,instr(version,'.',1,4)-1) p_vers_4d,
       substr(version,1,instr(version,'.',1,1)-1) p_vers_1d
from (select version from v$instance);
col p_vers_4d clear
col p_vers_1d clear

DECLARE
  V_VERS_1D NUMBER := '&p_vers_1d.';
  V_VERS_4D VARCHAR2(20) := '&p_vers_4d.';
BEGIN
  IF V_VERS_4D = '12.1.0.1' THEN
    NULL;
  ELSIF V_VERS_4D = '12.1.0.2' THEN
    execute immediate 'alter session set exclude_seed_cdb_view=false';
  ELSIF V_VERS_1D >= 12 THEN
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
