-- This code will clean the created objects.
WHENEVER SQLERROR EXIT SQL.SQLCODE

DROP DIRECTORY expdir;

DROP USER C##HASH CASCADE;

EXIT 0