-- This code will clean the created objects.
WHENEVER SQLERROR EXIT SQL.SQLCODE

DROP DIRECTORY expdir;

def v_username='&1.'

DROP USER &v_username. CASCADE;

EXIT 0