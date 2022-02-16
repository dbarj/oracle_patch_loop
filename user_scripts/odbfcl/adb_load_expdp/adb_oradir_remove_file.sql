WHENEVER SQLERROR EXIT SQL.SQLCODE

BEGIN
    DBMS_CLOUD.DELETE_FILE (
        directory_name       => 'DATA_PUMP_DIR',
        file_name            => '&1.');
END;
/