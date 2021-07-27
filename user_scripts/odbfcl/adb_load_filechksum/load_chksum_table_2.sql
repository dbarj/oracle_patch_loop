-- Check one day if loading from Object Storage is faster

WHENEVER SQLERROR EXIT SQL.SQLCODE

DEF P_CRED = '&1'
DEF P_URL = '&2'
DEF P_FILE = '&3'

BEGIN
 DBMS_CLOUD.COPY_DATA(
    table_name =>'T_FILES',
    credential_name =>'&P_CRED',
    file_uri_list =>'&P_URL/&P_FILE',
    format => json_object('type' value 'datapump')
 );
END;
/