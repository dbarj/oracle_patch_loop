-- This code will clean the created objects.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

def v_username='&1.'
def v_directory='&2.'
def v_drop_user='&3.'

DROP DIRECTORY &v_directory.;

BEGIN
  IF '&v_drop_user.' = 'true'
  THEN
    EXECUTE IMMEDIATE 'DROP USER &v_username. CASCADE';
  END IF;
END;
/

EXIT 0