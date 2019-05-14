-- This code is called just before the expdp. EXPDIR is used by expdp and must exist.
WHENEVER SQLERROR EXIT SQL.SQLCODE

CREATE OR REPLACE DIRECTORY expdir AS '&1';

EXIT 0