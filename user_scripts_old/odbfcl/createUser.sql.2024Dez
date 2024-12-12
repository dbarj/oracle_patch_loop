-- Create exporter user
WHENEVER SQLERROR CONTINUE

def v_username='&1.'
def v_password='&2.'
def v_data_tbs='&3.'
def v_temp_tbs='&4.'
def v_drop_user='&5.'

DECLARE
   USER_DOES_NOT_EXIST EXCEPTION;
   PRAGMA EXCEPTION_INIT(USER_DOES_NOT_EXIST, -1918);
BEGIN
  IF '&v_drop_user.' = 'true'
  THEN
    EXECUTE IMMEDIATE 'DROP USER &v_username. CASCADE';
  END IF;
EXCEPTION
   WHEN USER_DOES_NOT_EXIST THEN
      NULL;
END;
/

WHENEVER SQLERROR EXIT SQL.SQLCODE

CREATE USER &v_username.
  IDENTIFIED BY "&v_password."
  DEFAULT TABLESPACE "&v_data_tbs."
  TEMPORARY TABLESPACE "&v_temp_tbs."
  QUOTA UNLIMITED ON "&v_data_tbs.";

GRANT CREATE SESSION TO &v_username.;
GRANT CREATE TABLE TO &v_username.;

-- REMOVE_IF_ZIP_AFTER

-- This is no longer enabled after wrapper moved to PL/SQL

-- For unwrapper:
-- GRANT CREATE PROCEDURE TO &v_username.;