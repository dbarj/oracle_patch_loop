-- This code will clean the created objects.
WHENEVER SQLERROR EXIT SQL.SQLCODE

def v_username='&1.'
def v_directory='&2.'

DROP DIRECTORY &v_directory.;

DROP USER &v_username. CASCADE;

EXIT 0