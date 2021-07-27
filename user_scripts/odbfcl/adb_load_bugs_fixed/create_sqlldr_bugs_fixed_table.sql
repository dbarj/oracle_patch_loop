WHENEVER SQLERROR EXIT SQL.SQLCODE

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE T_BUGSFIXED_LOAD PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

CREATE TABLE T_BUGSFIXED_LOAD
(
  FILE_NAME  VARCHAR2(50)  NOT NULL,
  BUG_ID   NUMBER  NOT NULL,
  PATCH_ID NUMBER  NOT NULL,
  BUG_DESC VARCHAR2(1000 CHAR)
)
COMPRESS NOLOGGING;