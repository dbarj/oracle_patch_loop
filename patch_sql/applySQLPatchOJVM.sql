shutdown immediate;
startup upgrade;
@?/sqlpatch/&1/postinstall.sql
shutdown immediate;
startup;
@?/rdbms/admin/utlrp.sql
exit;
