WHENEVER SQLERROR EXIT SQL.SQLCODE

SET LINES 1000

DEF P_VERSION = '&1'
DEF P_SERIES  = '&2'
DEF P_PATCH   = '&3'

SET SERVEROUT ON
DECLARE

  --------------------------------------------

  FUNCTION IS_READY (
    P_OWNER         IN VARCHAR2,
    P_TABLENAME     IN VARCHAR2
  ) RETURN BOOLEAN
  IS
    V_RES NUMBER;
    V_CMD CLOB;
  BEGIN
    -- BE READY = FIND LINES TO UPDATE
    V_CMD := '
    SELECT 1 FROM DUAL
    WHERE EXISTS
      ( SELECT 1 FROM ' || DBMS_ASSERT.ENQUOTE_NAME(P_OWNER) || '.' || DBMS_ASSERT.ENQUOTE_NAME(P_TABLENAME) || '
        WHERE NOT ( ORAVERSION = ''&P_VERSION.'' AND
                    ORASERIES  = ''&P_SERIES.'' AND
                    ORAPATCH   = &P_PATCH.
                  ) OR ORAVERSION IS NULL OR ORASERIES IS NULL OR ORAPATCH IS NULL
      )';
    -- DBMS_OUTPUT.PUT_LINE(V_CMD || ';');
    EXECUTE IMMEDIATE  V_CMD
    INTO V_RES;
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END;

  --------------------------------------------

  PROCEDURE RUN_CMD (P_CMD CLOB)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(P_CMD || ';');
    EXECUTE IMMEDIATE P_CMD;
  END;

  --------------------------------------------

BEGIN
  FOR I IN (SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE 'T\_%' ESCAPE '\' ORDER BY TABLE_NAME)
  LOOP

    IF NOT IS_READY(USER,I.TABLE_NAME)
    THEN
      DBMS_OUTPUT.PUT_LINE( '--- ' || I.TABLE_NAME || ' - NOTHING TO DO');
      CONTINUE;
    END IF;

    RUN_CMD('UPDATE ' || DBMS_ASSERT.ENQUOTE_NAME(I.TABLE_NAME) || ' SET ORAVERSION = ''&P_VERSION.'', ORASERIES = ''&P_SERIES.'', ORAPATCH = &P_PATCH.');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQL%ROWCOUNT) || ' rows affected.');
    RUN_CMD('ALTER TABLE ' || DBMS_ASSERT.ENQUOTE_NAME(I.TABLE_NAME) || ' MOVE ONLINE');

  END LOOP;
END;
/

EXIT 0
