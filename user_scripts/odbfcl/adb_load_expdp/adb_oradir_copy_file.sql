WHENEVER SQLERROR EXIT SQL.SQLCODE

BEGIN
    DBMS_CLOUD.GET_OBJECT (
        credential_name      => '&1.',
        object_uri           => '&2.',
        directory_name       => 'DATA_PUMP_DIR');
END;
/