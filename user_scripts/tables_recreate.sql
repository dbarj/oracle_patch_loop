WHENEVER SQLERROR EXIT SQL.SQLCODE

col v_username new_v v_username nopri

select case when version >= 12 then 'C##HASH' else 'HASH' end v_username
from  (select to_number(substr(version,1,instr(version,'.')-1)) version
         from v$instance);

col v_username clear

conn &&v_username./hash;

set serverout on
DECLARE
  VCODE CLOB;
BEGIN
  FOR I IN (select table_name from sys.user_tables)
  LOOP
    VCODE := 'DROP TABLE ' || DBMS_ASSERT.SQL_OBJECT_NAME(I.TABLE_NAME) || ' CASCADE CONSTRAINTS PURGE';
    DBMS_OUTPUT.PUT_LINE(VCODE);
    EXECUTE IMMEDIATE VCODE;
  END LOOP;
END;
/

@@tables_create.sql
