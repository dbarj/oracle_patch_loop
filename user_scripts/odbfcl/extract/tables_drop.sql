-- drop table for internal objects
@@internal_schemas/int_resources_drop.sql

-- drop non-loaded tables when internal mode is used
DECLARE
  TYPE V_STR_LIST IS TABLE OF VARCHAR2(30);
  V_LIST V_STR_LIST;
  V_SQL VARCHAR2(32767); -- 10.2 does not support CLOB for EXECUTE IMMEDIATE
BEGIN
  V_LIST := V_STR_LIST('DM_CONTENTS', 'T_TXTCOLLECTION', 'T_SYMBOLS');
  IF '&v_internal' = 'true'
  THEN
    FOR I IN V_LIST.FIRST .. V_LIST.LAST
    LOOP
      V_SQL := 'DROP TABLE &v_username..' || V_LIST(I) || ' PURGE';
      DBMS_OUTPUT.PUT_LINE(V_SQL || ';');
      EXECUTE IMMEDIATE V_SQL;
    END LOOP;
  END IF;
END;
/