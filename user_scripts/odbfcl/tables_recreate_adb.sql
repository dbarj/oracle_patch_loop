WHENEVER SQLERROR EXIT SQL.SQLCODE

SET LINES 1000 PAGES 1000

SET SERVEROUT ON
DECLARE
  VCODE CLOB;
BEGIN
  FOR I IN (select table_name from sys.user_tables order by 1)
  LOOP
    VCODE := 'DROP TABLE ' || DBMS_ASSERT.SQL_OBJECT_NAME(I.TABLE_NAME) || ' CASCADE CONSTRAINTS PURGE';
    DBMS_OUTPUT.PUT_LINE(VCODE);
    EXECUTE IMMEDIATE VCODE;
  END LOOP;
END;
/

-- @@tables_create.sql

DECLARE
  V_CMD CLOB;
BEGIN
  FOR I IN (SELECT TABLE_NAME
            FROM SYS.ALL_TABLES
            WHERE OWNER='HASH'
            AND (TABLE_NAME LIKE 'T\_%' ESCAPE '\' OR TABLE_NAME LIKE 'DM\_%' ESCAPE '\')
            ORDER BY 1)
  LOOP
    V_CMD := 'CREATE TABLE ' || DBMS_ASSERT.ENQUOTE_NAME(I.TABLE_NAME) || ' FOR EXCHANGE WITH TABLE ' || DBMS_ASSERT.ENQUOTE_NAME('HASH') || '.' || DBMS_ASSERT.ENQUOTE_NAME(I.TABLE_NAME);
    DBMS_OUTPUT.PUT_LINE(V_CMD || ';');
    EXECUTE IMMEDIATE V_CMD;
  END LOOP;
END;
/

-- As the datapump dump tables does not contain ORAVERSION / ORASERIES / ORAPATCH fields, keep it as null.
DECLARE
  V_CMD CLOB;
BEGIN
  FOR I IN (SELECT TABLE_NAME FROM SYS.USER_TABLES WHERE TABLE_NAME LIKE 'T_\%' ESCAPE '\')
  LOOP
    V_CMD := 'ALTER TABLE ' || DBMS_ASSERT.SQL_OBJECT_NAME(I.TABLE_NAME) || '
              MODIFY ( "ORAVERSION" NULL,
                       "ORASERIES"  NULL,
                       "ORAPATCH"   NULL )';
    DBMS_OUTPUT.PUT_LINE(V_CMD || ';');
    EXECUTE IMMEDIATE V_CMD;
  END LOOP;
END;
/