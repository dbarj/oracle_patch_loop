-- This code is called just before the expdp. The DB directory is used by expdp and must exist.
WHENEVER SQLERROR EXIT SQL.SQLCODE

def v_path='&1.'
def v_username='&2.'
def v_dir_name='&3.'

CREATE OR REPLACE DIRECTORY &v_dir_name. AS '&v_path.';

GRANT READ,WRITE ON DIRECTORY &v_dir_name. to &v_username.;

EXIT 0