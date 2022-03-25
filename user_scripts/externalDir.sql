-- This code is called just before the expdp. EXPDIR is used by expdp and must exist.
WHENEVER SQLERROR EXIT SQL.SQLCODE

CREATE OR REPLACE DIRECTORY expdir AS '&1';

def v_username='&2.'

GRANT READ,WRITE ON DIRECTORY expdir to &v_username.;

EXIT 0