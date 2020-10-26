---------------------------------------------------
@@insert_all_privs_clean "T_TAB_PRIVS"
@@insert_all_privs_clean "T_COL_PRIVS"
@@insert_all_privs_clean "T_SYS_PRIVS"
@@insert_all_privs_clean "T_ROLE_PRIVS"
@@insert_all_privs_clean "T_JAVA_POLICY"
@@insert_all_privs_clean "T_JOBS"
@@insert_all_privs_clean "T_SYNONYMS"
@@insert_all_privs_clean "T_TS_QUOTAS"
@@insert_all_privs_clean "T_POLICIES"
@@insert_all_privs_clean "T_TRIGGERS"
@@insert_all_privs_clean "T_SCHEDULER_JOBS"
@@insert_all_privs_clean "T_SCHEDULER_PROGRAMS"
@@insert_all_privs_clean "T_OBJ_AUDIT_OPTS"
@@insert_all_privs_clean "T_STMT_AUDIT_OPTS"
@@insert_all_privs_clean "T_PRIV_AUDIT_OPTS"
@@insert_all_privs_clean "T_AUDIT_POLICIES"
@@insert_all_privs_clean "T_AUDIT_POLICY_COLUMNS"
@@insert_all_privs_clean "T_AUDIT_UNIFIED_POLICIES"
---------------------------------------------------

set lines 1000

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_TAB_PRIVS"
exec :v_table_cols := 'GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE,HIERARCHY,TYPE,INHERITED,COMMON';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := 'GRANTEE,OWNER,TABLE_NAME,GRANTOR,PRIVILEGE,GRANTABLE,HIERARCHY,TYPE,TABLE_NAME_COMP,INHERITED,COMMON,CON_ID';
def v_file_pref = 'privs_tab'
def v_srczip_pref = 'privs'

@@insert_all_privs_code
@@change_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_COL_PRIVS"
exec :v_table_cols := 'GRANTEE,OWNER,TABLE_NAME,COLUMN_NAME,GRANTOR,PRIVILEGE,GRANTABLE,INHERITED,COMMON';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'privs_col'
def v_srczip_pref = 'privs'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_SYS_PRIVS"
exec :v_table_cols := 'GRANTEE,PRIVILEGE,ADMIN_OPTION,INHERITED,COMMON';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'privs_sys'
def v_srczip_pref = 'privs'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_ROLE_PRIVS"
exec :v_table_cols := 'GRANTEE,GRANTED_ROLE,ADMIN_OPTION,DEFAULT_ROLE,DELEGATE_OPTION,INHERITED,COMMON';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'privs_rol'
def v_srczip_pref = 'privs'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_JAVA_POLICY"
exec :v_table_cols := 'KIND,GRANTEE,TYPE_SCHEMA,TYPE_NAME,NAME,ACTION,ENABLED';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'java_pol'
def v_srczip_pref = 'java_pol'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_JOBS"
exec :v_table_cols := 'LOG_USER,PRIV_USER,SCHEMA_USER,BROKEN,INTERVAL,WHAT,INSTANCE';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'legacy_jobs'
def v_srczip_pref = 'sched'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_SYNONYMS"
exec :v_table_cols := 'OWNER,SYNONYM_NAME,TABLE_OWNER,TABLE_NAME,DB_LINK';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'synonyms'
def v_srczip_pref = 'synonyms'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_TS_QUOTAS"
exec :v_table_cols := 'TABLESPACE_NAME,USERNAME,MAX_BYTES,MAX_BLOCKS,DROPPED';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'ts_quotas'
def v_srczip_pref = 'ts_quotas'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_POLICIES"
exec :v_table_cols := 'OBJECT_OWNER,OBJECT_NAME,POLICY_GROUP,POLICY_NAME,PF_OWNER,PACKAGE,FUNCTION,SEL,INS,UPD,DEL,IDX,CHK_OPTION,ENABLE,STATIC_POLICY,POLICY_TYPE,LONG_PREDICATE,INHERITED,COMMON';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'policies'
def v_srczip_pref = 'policies'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_TRIGGERS"
exec :v_table_cols := 'OWNER,TRIGGER_NAME,TRIGGER_TYPE,TRIGGERING_EVENT,TABLE_OWNER,BASE_OBJECT_TYPE,TABLE_NAME,COLUMN_NAME,REFERENCING_NAMES,WHEN_CLAUSE,STATUS,DESCRIPTION,ACTION_TYPE,CROSSEDITION,BEFORE_STATEMENT,BEFORE_ROW,AFTER_ROW,AFTER_STATEMENT,INSTEAD_OF_ROW,FIRE_ONCE,APPLY_SERVER_ONLY';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'triggers'
def v_srczip_pref = 'triggers'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_SCHEDULER_JOBS"
exec :v_table_cols := 'OWNER,JOB_NAME,JOB_SUBNAME,JOB_STYLE,JOB_CREATOR,CLIENT_ID,GLOBAL_UID,PROGRAM_OWNER,PROGRAM_NAME,JOB_TYPE,JOB_ACTION,NUMBER_OF_ARGUMENTS,SCHEDULE_OWNER,SCHEDULE_NAME,SCHEDULE_TYPE,REPEAT_INTERVAL,EVENT_QUEUE_OWNER,EVENT_QUEUE_NAME,EVENT_QUEUE_AGENT,EVENT_CONDITION,EVENT_RULE,FILE_WATCHER_OWNER,FILE_WATCHER_NAME,END_DATE,JOB_CLASS,ENABLED,AUTO_DROP,RESTART_ON_RECOVERY,RESTART_ON_FAILURE,STATE,JOB_PRIORITY,MAX_RUNS,FAILURE_COUNT,MAX_FAILURES,RETRY_COUNT,SCHEDULE_LIMIT,MAX_RUN_DURATION,LOGGING_LEVEL,STORE_OUTPUT,STOP_ON_WINDOW_CLOSE,INSTANCE_STICKINESS,RAISE_EVENTS,SYSTEM,JOB_WEIGHT,SOURCE,NUMBER_OF_DESTINATIONS,DESTINATION_OWNER,DESTINATION,CREDENTIAL_OWNER,CREDENTIAL_NAME,INSTANCE_ID,DEFERRED_DROP,ALLOW_RUNS_IN_RESTRICTED_MODE,COMMENTS,FLAGS,RESTARTABLE,HAS_CONSTRAINTS,CONNECT_CREDENTIAL_OWNER,CONNECT_CREDENTIAL_NAME,FAIL_ON_SCRIPT_ERROR';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'jobs'
def v_srczip_pref = 'sched'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_SCHEDULER_PROGRAMS"
exec :v_table_cols := 'OWNER,PROGRAM_NAME,PROGRAM_TYPE,PROGRAM_ACTION,NUMBER_OF_ARGUMENTS,ENABLED,DETACHED,SCHEDULE_LIMIT,PRIORITY,WEIGHT,MAX_RUNS,MAX_FAILURES,MAX_RUN_DURATION,HAS_CONSTRAINTS,COMMENTS';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'programs'
def v_srczip_pref = 'sched'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_OBJ_AUDIT_OPTS"
exec :v_table_cols := 'OWNER,OBJECT_NAME,OBJECT_TYPE,ALT,AUD,COM,DEL,GRA,IND,INS,LOC,REN,SEL,UPD,REF,EXE,CRE,REA,WRI,FBK';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'obj_audit_opts'
def v_srczip_pref = 'audit'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_STMT_AUDIT_OPTS"
exec :v_table_cols := 'USER_NAME,PROXY_NAME,AUDIT_OPTION,SUCCESS,FAILURE';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'stmt_audit_opts'
def v_srczip_pref = 'audit'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_PRIV_AUDIT_OPTS"
exec :v_table_cols := 'USER_NAME,PROXY_NAME,PRIVILEGE,SUCCESS,FAILURE';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'priv_audit_opts'
def v_srczip_pref = 'audit'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_AUDIT_POLICIES"
exec :v_table_cols := 'OBJECT_SCHEMA,OBJECT_NAME,POLICY_OWNER,POLICY_NAME,POLICY_TEXT,POLICY_COLUMN,PF_SCHEMA,PF_PACKAGE,PF_FUNCTION,ENABLED,SEL,INS,UPD,DEL,AUDIT_TRAIL,POLICY_COLUMN_OPTIONS';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'audit_policies'
def v_srczip_pref = 'audit'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_AUDIT_POLICY_COLUMNS"
exec :v_table_cols := 'OBJECT_SCHEMA,OBJECT_NAME,POLICY_NAME,POLICY_COLUMN';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'audit_policy_columns'
def v_srczip_pref = 'audit'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_AUDIT_UNIFIED_POLICIES"
exec :v_table_cols := 'POLICY_NAME,AUDIT_CONDITION,CONDITION_EVAL_OPT,AUDIT_OPTION,AUDIT_OPTION_TYPE,OBJECT_SCHEMA,OBJECT_NAME,OBJECT_TYPE,INHERITED,COMMON';
exec :v_table_id_cols := :v_table_cols || ',HASH_LINE_ID,CON_ID,ORAVERSION';

def v_hash_col_id = "HASH_LINE_ID"
def v_print_table = "&&v_table_name."
exec :v_print_cols := :v_table_cols || ',CON_ID';
def v_file_pref = 'audit_unified_policies'
def v_srczip_pref = 'audit'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------
-----------------------------
-----------------------------

-- select listagg(column_name,',') within group(order by COLUMN_ID) from user_tab_columns where table_name='T_DV_REALM';
-- select count(*) from T_DV_REALM;
-- select distinct NAME,DESCRIPTION,AUDIT_OPTIONS,REALM_TYPE,COMMON,INHERITED,ENABLED,ID#,ORACLE_SUPPLIED,PL_SQL_STACK from T_DV_REALM;

-----------------------------