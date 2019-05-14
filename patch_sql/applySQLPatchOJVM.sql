-- Param 1 will be the patch ID to be applied
shutdown immediate;
startup upgrade;
@?/sqlpatch/&1/postinstall.sql
shutdown immediate;
startup;
@?/rdbms/admin/utlrp.sql
exit;
