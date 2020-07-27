WHENEVER SQLERROR EXIT SQL.SQLCODE

set serverout on

col user_prefix new_v user_prefix nopri

select case when version >= 12 then 'C##' else '' end user_prefix
from  (select to_number(substr(version,1,instr(version,'.')-1)) version
         from v$instance);

col user_prefix clear

alter session set current_schema=&&user_prefix.HASH;

DECLARE
  VCODE CLOB;
BEGIN
  FOR I IN (select owner,table_name from sys.all_tables where owner=SYS_CONTEXT('USERENV','CURRENT_SCHEMA'))
  LOOP
    VCODE := 'TRUNCATE TABLE ' || DBMS_ASSERT.SCHEMA_NAME(I.OWNER) || '.' || DBMS_ASSERT.SQL_OBJECT_NAME(I.TABLE_NAME);
    DBMS_OUTPUT.PUT_LINE(VCODE);
    EXECUTE IMMEDIATE VCODE;
  END LOOP;
END;
/