---------------------------------------------------
@@insert_all_privs_clean "T_DV_COMMAND_RULE"
@@insert_all_privs_clean "T_DV_REALM"
@@insert_all_privs_clean "T_DV_REALM_AUTH"
@@insert_all_privs_clean "T_DV_REALM_OBJECT"
@@insert_all_privs_clean "T_DV_RULE"
@@insert_all_privs_clean "T_DV_RULE_SET"
---------------------------------------------------

set lines 1000

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_DV_COMMAND_RULE"
exec :v_table_cols := 'COMMAND,CLAUSE_NAME,PARAMETER_NAME,EVENT_NAME,COMPONENT_NAME,ACTION_NAME,RULE_SET_NAME,OBJECT_OWNER,OBJECT_NAME,ENABLED,PRIVILEGE_SCOPE,COMMON,INHERITED,ID#,ORACLE_SUPPLIED,PL_SQL_STACK';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'dv_command_rule'
def v_srczip_pref = 'dbvault'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_DV_REALM"
exec :v_table_cols := 'NAME,DESCRIPTION,AUDIT_OPTIONS,REALM_TYPE,COMMON,INHERITED,ENABLED,ID#,ORACLE_SUPPLIED,PL_SQL_STACK';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'dv_realm'
def v_srczip_pref = 'dbvault'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_DV_REALM_AUTH"
exec :v_table_cols := 'REALM_NAME,COMMON_REALM,INHERITED_REALM,GRANTEE,AUTH_RULE_SET_NAME,AUTH_OPTIONS,COMMON_AUTH,INHERITED_AUTH';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'dv_realm_auth'
def v_srczip_pref = 'dbvault'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_DV_REALM_OBJECT"
exec :v_table_cols := 'REALM_NAME,COMMON_REALM,INHERITED_REALM,OWNER,OBJECT_NAME,OBJECT_TYPE';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'dv_realm_object'
def v_srczip_pref = 'dbvault'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_DV_RULE"
exec :v_table_cols := 'NAME,RULE_EXPR,COMMON,INHERITED,ID#,ORACLE_SUPPLIED';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'dv_rule'
def v_srczip_pref = 'dbvault'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_DV_RULE_SET"
exec :v_table_cols := 'RULE_SET_NAME,DESCRIPTION,ENABLED,EVAL_OPTIONS_MEANING,AUDIT_OPTIONS,FAIL_OPTIONS_MEANING,FAIL_MESSAGE,FAIL_CODE,HANDLER_OPTIONS,HANDLER,IS_STATIC,COMMON,INHERITED,ID#,ORACLE_SUPPLIED';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'dv_rule_set'
def v_srczip_pref = 'dbvault'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------
-----------------------------
-----------------------------

-- select listagg(column_name,',') within group(order by COLUMN_ID) from user_tab_columns where table_name='T_DV_REALM';
-- select count(*) from T_DV_REALM;
-- select distinct NAME,DESCRIPTION,AUDIT_OPTIONS,REALM_TYPE,COMMON,INHERITED,ENABLED,ID#,ORACLE_SUPPLIED,PL_SQL_STACK from T_DV_REALM;

-----------------------------