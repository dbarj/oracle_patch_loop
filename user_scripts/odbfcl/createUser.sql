-- Create HASH user
WHENEVER SQLERROR CONTINUE

def v_username='&1.'
def v_password='&2.'
def v_data_tbs='&3.'
def v_temp_tbs='&4.'

DROP USER &v_username. CASCADE;

WHENEVER SQLERROR EXIT SQL.SQLCODE

CREATE USER &v_username.
  IDENTIFIED BY "&v_password."
  DEFAULT TABLESPACE "&v_data_tbs."
  TEMPORARY TABLESPACE "&v_temp_tbs."
  QUOTA UNLIMITED ON "&v_data_tbs.";

GRANT CREATE SESSION TO &v_username.;
GRANT CREATE TABLE TO &v_username.;
-- For unwrapper:
GRANT CREATE PROCEDURE TO &v_username.;