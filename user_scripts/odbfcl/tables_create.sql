WHENEVER SQLERROR EXIT SQL.SQLCODE

-- Tables:

----------------
-- From X$:
----------------
-- T_PARAMETER
-- T_PARAMETERVAL
-- T_XTABCOLS

----------------
-- From V$:
----------------
-- T_FIXED_TABLE
-- T_FIXED_VIEW_DEFINITION
-- T_SYSSTAT
-- T_SYS_TIME_MODEL
-- T_EVENT_NAME

----------------
-- From DBA/DBA:
----------------
-- T_TAB_PRIVS
-- T_COL_PRIVS
-- T_SYS_PRIVS
-- T_ROLE_PRIVS
-- T_JAVA_POLICY
-- T_JOBS
-- T_TS_QUOTAS
-- T_POLICIES
-- T_TRIGGERS
-- T_SCHEDULER_JOBS
-- T_SCHEDULER_PROGRAMS
-- T_OBJ_AUDIT_OPTS
-- T_STMT_AUDIT_OPTS
-- T_PRIV_AUDIT_OPTS
-- T_AUDIT_POLICIES
-- T_AUDIT_POLICY_COLUMNS
-- T_SYNONYMS
-- T_USERS
-- T_ROLES
-- T_OBJECTS
-- T_TAB_COLUMNS

----------------
-- From Others:
----------------
-- T_HASH
-- T_AUDIT_UNIFIED_POLICIES
-- T_FILES
-- T_SYMBOLS
-- T_TXTCOLLECTION

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

CREATE TABLE "T_PARAMETER"
(
"NAME" VARCHAR2(80 CHAR) NOT NULL,
"TYPE" NUMBER,
"DEFAULT_VALUE" VARCHAR2(255 CHAR),
"ISSES_MODIFIABLE" VARCHAR2(5 CHAR),
"ISSYS_MODIFIABLE" VARCHAR2(9 CHAR),
"ISPDB_MODIFIABLE" VARCHAR2(5 CHAR),
"ISINSTANCE_MODIFIABLE" VARCHAR2(5 CHAR),
"ISDEPRECATED" VARCHAR2(5 CHAR),
"ISBASIC" VARCHAR2(5 CHAR),
"DESCRIPTION" VARCHAR2(255 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_PARAMETER_VALID_VALUES"
(
"NAME" VARCHAR2(80 CHAR) NOT NULL,
"ORDINAL" NUMBER,
"VALUE" VARCHAR2(255 CHAR) NOT NULL,
"ISDEFAULT" VARCHAR2(64 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SYSSTAT"
(
"STATISTIC#" NUMBER,
"NAME" VARCHAR2(64 CHAR),
"CLASS" NUMBER,
"STAT_ID" NUMBER NOT NULL,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SYS_TIME_MODEL"
(
"STAT_ID" NUMBER NOT NULL,
"STAT_NAME" VARCHAR2(64 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_EVENT_NAME"
(
"EVENT#" NUMBER,
"EVENT_ID" NUMBER NOT NULL,
"NAME" VARCHAR2(64 CHAR),
"PARAMETER1" VARCHAR2(64 CHAR),
"PARAMETER2" VARCHAR2(64 CHAR),
"PARAMETER3" VARCHAR2(64 CHAR),
"WAIT_CLASS_ID" NUMBER,
"WAIT_CLASS#" NUMBER,
"WAIT_CLASS" VARCHAR2(64 CHAR),
"DISPLAY_NAME" VARCHAR2(64 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_XTABCOLS"
(
"TABLE_NAME" VARCHAR2(128 CHAR) NOT NULL,
"COLUMN_NAME" VARCHAR2(128 CHAR) NOT NULL,
"COLUMN_TYPE" NUMBER,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_OBJECTS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"OBJECT_NAME" VARCHAR2(128 CHAR) NOT NULL,
"SUBOBJECT_NAME" VARCHAR2(128 CHAR),
"OBJECT_TYPE" VARCHAR2(23 CHAR) NOT NULL,
"TEMPORARY" VARCHAR2(1 CHAR),
"GENERATED" VARCHAR2(1 CHAR),
"SECONDARY" VARCHAR2(1 CHAR),
"NAMESPACE" NUMBER,
"EDITION_NAME" VARCHAR2(128 CHAR),
"SHARING" VARCHAR2(18 CHAR),
"EDITIONABLE" VARCHAR2(1 CHAR),
"ORACLE_MAINTAINED" VARCHAR2(1 CHAR),
"APPLICATION" VARCHAR2(1 CHAR),
"DEFAULT_COLLATION" VARCHAR2(100 CHAR),
"DUPLICATED" VARCHAR2(1 CHAR),
"SHARDED" VARCHAR2(1 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_TAB_COLUMNS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"TABLE_NAME" VARCHAR2(128 CHAR) NOT NULL,
"COLUMN_NAME" VARCHAR2(128 CHAR) NOT NULL,
"DATA_TYPE" VARCHAR2(128 CHAR),
"DATA_TYPE_MOD" VARCHAR2(3 CHAR),
"DATA_TYPE_OWNER" VARCHAR2(128 CHAR),
"DATA_LENGTH" NUMBER,
"DATA_PRECISION" NUMBER,
"DATA_SCALE" NUMBER,
"NULLABLE" VARCHAR2(1 CHAR),
"COLUMN_ID" NUMBER,
"DEFAULT_LENGTH" NUMBER,
"CHARACTER_SET_NAME" VARCHAR2(44 CHAR),
"CHAR_COL_DECL_LENGTH" NUMBER,
"DEFAULT_ON_NULL" VARCHAR2(3 CHAR),
"IDENTITY_COLUMN" VARCHAR2(3 CHAR),
"SENSITIVE_COLUMN" VARCHAR2(3 CHAR),
"COLLATION" VARCHAR2(100 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_FIXED_TABLE"
(
"NAME" VARCHAR2(128 CHAR) NOT NULL,
"TYPE" VARCHAR2(5 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_FIXED_VIEW_DEFINITION"
(
"VIEW_NAME" VARCHAR2(128 CHAR) NOT NULL,
"VIEW_DEFINITION" VARCHAR2(4000 CHAR),
"VIEW_DEFINITION_CLOB" CLOB,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_USERS"
(
"USERNAME" VARCHAR2(128 CHAR) NOT NULL,
"USER_ID" NUMBER,
"ACCOUNT_STATUS" VARCHAR2(32 CHAR),
"DEFAULT_TABLESPACE" VARCHAR2(30 CHAR),
"TEMPORARY_TABLESPACE" VARCHAR2(30 CHAR),
"LOCAL_TEMP_TABLESPACE" VARCHAR2(30 CHAR),
"PROFILE" VARCHAR2(128 CHAR),
"INITIAL_RSRC_CONSUMER_GROUP" VARCHAR2(128 CHAR),
"EXTERNAL_NAME" VARCHAR2(4000 CHAR),
"PASSWORD_VERSIONS" VARCHAR2(17 CHAR),
"EDITIONS_ENABLED" VARCHAR2(1 CHAR),
"AUTHENTICATION_TYPE" VARCHAR2(8 CHAR),
"PROXY_ONLY_CONNECT" VARCHAR2(1 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"ORACLE_MAINTAINED" VARCHAR2(1 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"DEFAULT_COLLATION" VARCHAR2(100 CHAR),
"IMPLICIT" VARCHAR2(3 CHAR),
"ALL_SHARD" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_ROLES"
(
"ROLE" VARCHAR2(128 CHAR) NOT NULL,
"PASSWORD_REQUIRED" VARCHAR2(8 CHAR),
"AUTHENTICATION_TYPE" VARCHAR2(11 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"ORACLE_MAINTAINED" VARCHAR2(1 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"IMPLICIT" VARCHAR2(3 CHAR),
"EXTERNAL_NAME" VARCHAR2(4000 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_RESERVED_WORDS"
(
"KEYWORD" VARCHAR2(128 CHAR),
"LENGTH" NUMBER,
"RESERVED" VARCHAR2(1 CHAR),
"RES_TYPE" VARCHAR2(1 CHAR),
"RES_ATTR" VARCHAR2(1 CHAR),
"RES_SEMI" VARCHAR2(1 CHAR),
"DUPLICATE" VARCHAR2(1 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SYSTEM_FIX_CONTROL"
(
"BUGNO" NUMBER NOT NULL,
"VALUE" NUMBER,
"SQL_FEATURE" VARCHAR2(64 CHAR), -- NOT NULL, -- Found NULL entry on 12.1.0.2 - 18907562
"DESCRIPTION" VARCHAR2(64 CHAR),
"OPTIMIZER_FEATURE_ENABLE" VARCHAR2(25 CHAR),
"EVENT" NUMBER,
"IS_DEFAULT" NUMBER,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_TRIGGERS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"TRIGGER_NAME" VARCHAR2(128 CHAR) NOT NULL,
"TRIGGER_TYPE" VARCHAR2(16 CHAR),
"TRIGGERING_EVENT" VARCHAR2(246 CHAR),
"TABLE_OWNER" VARCHAR2(128 CHAR),
"BASE_OBJECT_TYPE" VARCHAR2(18 CHAR),
"TABLE_NAME" VARCHAR2(128 CHAR),
"COLUMN_NAME" VARCHAR2(4000 CHAR),
"REFERENCING_NAMES" VARCHAR2(422 CHAR),
"WHEN_CLAUSE" VARCHAR2(4000 CHAR),
"STATUS" VARCHAR2(8 CHAR),
"DESCRIPTION" VARCHAR2(4000 CHAR),
"ACTION_TYPE" VARCHAR2(11 CHAR),
"CROSSEDITION" VARCHAR2(7 CHAR),
"BEFORE_STATEMENT" VARCHAR2(3 CHAR),
"BEFORE_ROW" VARCHAR2(3 CHAR),
"AFTER_ROW" VARCHAR2(3 CHAR),
"AFTER_STATEMENT" VARCHAR2(3 CHAR),
"INSTEAD_OF_ROW" VARCHAR2(3 CHAR),
"FIRE_ONCE" VARCHAR2(3 CHAR),
"APPLY_SERVER_ONLY" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_AUDIT_POLICY_COLUMNS"
(
"OBJECT_SCHEMA" VARCHAR2(128 CHAR),
"OBJECT_NAME" VARCHAR2(128 CHAR),
"POLICY_NAME" VARCHAR2(128 CHAR),
"POLICY_COLUMN" VARCHAR2(128 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_AUDIT_UNIFIED_POLICIES"
(
"POLICY_NAME" VARCHAR2(128 CHAR) NOT NULL,
"AUDIT_CONDITION" VARCHAR2(4000 CHAR) NOT NULL,
"CONDITION_EVAL_OPT" VARCHAR2(9 CHAR) NOT NULL,
"AUDIT_OPTION" VARCHAR2(128 CHAR) NOT NULL,
"AUDIT_OPTION_TYPE" VARCHAR2(18 CHAR) NOT NULL,
"OBJECT_SCHEMA" VARCHAR2(128 CHAR) NOT NULL,
"OBJECT_NAME" VARCHAR2(128 CHAR) NOT NULL,
"OBJECT_TYPE" VARCHAR2(23 CHAR) NOT NULL,
"COMMON" VARCHAR2(3 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_COL_PRIVS"
(
"GRANTEE" VARCHAR2(128 CHAR) NOT NULL,
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"TABLE_NAME" VARCHAR2(128 CHAR) NOT NULL,
"COLUMN_NAME" VARCHAR2(128 CHAR) NOT NULL,
"GRANTOR" VARCHAR2(128 CHAR),
"PRIVILEGE" VARCHAR2(40 CHAR) NOT NULL,
"GRANTABLE" VARCHAR2(3 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SCHEDULER_PROGRAMS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"PROGRAM_NAME" VARCHAR2(128 CHAR) NOT NULL,
"PROGRAM_TYPE" VARCHAR2(16 CHAR),
"PROGRAM_ACTION" VARCHAR2(4000 CHAR),
"NUMBER_OF_ARGUMENTS" NUMBER,
"ENABLED" VARCHAR2(5 CHAR),
"DETACHED" VARCHAR2(5 CHAR),
"SCHEDULE_LIMIT" INTERVAL DAY (3) TO SECOND (0),
"PRIORITY" NUMBER,
"WEIGHT" NUMBER,
"MAX_RUNS" NUMBER,
"MAX_FAILURES" NUMBER,
"MAX_RUN_DURATION" INTERVAL DAY (3) TO SECOND (0),
"HAS_CONSTRAINTS" VARCHAR2(5 CHAR),
"NLS_ENV" VARCHAR2(4000 CHAR),
"COMMENTS" VARCHAR2(4000 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_JOBS"
(
"JOB" NUMBER,
"LOG_USER" VARCHAR2(128 CHAR),
"PRIV_USER" VARCHAR2(128 CHAR),
"SCHEMA_USER" VARCHAR2(128 CHAR) NOT NULL,
"LAST_DATE" DATE,
"LAST_SEC" VARCHAR2(8 CHAR),
"THIS_DATE" DATE,
"THIS_SEC" VARCHAR2(8 CHAR),
"NEXT_DATE" DATE,
"NEXT_SEC" VARCHAR2(8 CHAR),
"TOTAL_TIME" NUMBER,
"BROKEN" VARCHAR2(1 CHAR),
"INTERVAL" VARCHAR2(200 CHAR),
"FAILURES" NUMBER,
"WHAT" VARCHAR2(4000 CHAR) NOT NULL,
"NLS_ENV" VARCHAR2(4000 CHAR),
"MISC_ENV" RAW(32),
"INSTANCE" NUMBER,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_TAB_PRIVS"
(
"GRANTEE" VARCHAR2(128 CHAR) NOT NULL,
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"TABLE_NAME" VARCHAR2(128 CHAR) NOT NULL,
"GRANTOR" VARCHAR2(128 CHAR),
"PRIVILEGE" VARCHAR2(40 CHAR) NOT NULL,
"GRANTABLE" VARCHAR2(3 CHAR),
"HIERARCHY" VARCHAR2(3 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"TYPE" VARCHAR2(24 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_PRIV_AUDIT_OPTS"
(
"USER_NAME" VARCHAR2(128 CHAR),
"PROXY_NAME" VARCHAR2(128 CHAR),
"PRIVILEGE" VARCHAR2(40 CHAR) NOT NULL,
"SUCCESS" VARCHAR2(10 CHAR),
"FAILURE" VARCHAR2(10 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_TS_QUOTAS"
(
"TABLESPACE_NAME" VARCHAR2(30 CHAR) NOT NULL,
"USERNAME" VARCHAR2(128 CHAR) NOT NULL,
"BYTES" NUMBER,
"MAX_BYTES" NUMBER,
"BLOCKS" NUMBER,
"MAX_BLOCKS" NUMBER,
"DROPPED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_OBJ_AUDIT_OPTS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"OBJECT_NAME" VARCHAR2(128 CHAR) NOT NULL,
"OBJECT_TYPE" VARCHAR2(23 CHAR) NOT NULL,
"ALT" VARCHAR2(3 CHAR),
"AUD" VARCHAR2(3 CHAR),
"COM" VARCHAR2(3 CHAR),
"DEL" VARCHAR2(3 CHAR),
"GRA" VARCHAR2(3 CHAR),
"IND" VARCHAR2(3 CHAR),
"INS" VARCHAR2(3 CHAR),
"LOC" VARCHAR2(3 CHAR),
"REN" VARCHAR2(3 CHAR),
"SEL" VARCHAR2(3 CHAR),
"UPD" VARCHAR2(3 CHAR),
"REF" CHAR(3 CHAR),
"EXE" VARCHAR2(3 CHAR),
"CRE" VARCHAR2(3 CHAR),
"REA" VARCHAR2(3 CHAR),
"WRI" VARCHAR2(3 CHAR),
"FBK" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_STMT_AUDIT_OPTS"
(
"USER_NAME" VARCHAR2(128 CHAR),
"PROXY_NAME" VARCHAR2(128 CHAR),
"AUDIT_OPTION" VARCHAR2(40 CHAR) NOT NULL,
"SUCCESS" VARCHAR2(10 CHAR),
"FAILURE" VARCHAR2(10 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_POLICIES"
(
"OBJECT_OWNER" VARCHAR2(128 CHAR) NOT NULL,
"OBJECT_NAME" VARCHAR2(128 CHAR),
"POLICY_GROUP" VARCHAR2(128 CHAR),
"POLICY_NAME" VARCHAR2(128 CHAR) NOT NULL,
"PF_OWNER" VARCHAR2(128 CHAR),
"PACKAGE" VARCHAR2(128 CHAR),
"FUNCTION" VARCHAR2(128 CHAR),
"SEL" VARCHAR2(3 CHAR),
"INS" VARCHAR2(3 CHAR),
"UPD" VARCHAR2(3 CHAR),
"DEL" VARCHAR2(3 CHAR),
"IDX" VARCHAR2(3 CHAR),
"CHK_OPTION" VARCHAR2(3 CHAR),
"ENABLE" VARCHAR2(3 CHAR),
"STATIC_POLICY" VARCHAR2(3 CHAR),
"POLICY_TYPE" VARCHAR2(24 CHAR),
"LONG_PREDICATE" VARCHAR2(3 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_ROLE_PRIVS"
(
"GRANTEE" VARCHAR2(128 CHAR) NOT NULL,
"GRANTED_ROLE" VARCHAR2(128 CHAR) NOT NULL,
"ADMIN_OPTION" VARCHAR2(3 CHAR),
"DELEGATE_OPTION" VARCHAR2(3 CHAR),
"DEFAULT_ROLE" VARCHAR2(3 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_JAVA_POLICY"
(
"KIND" VARCHAR2(8 CHAR) NOT NULL,
"GRANTEE" VARCHAR2(128 CHAR) NOT NULL,
"TYPE_SCHEMA" VARCHAR2(128 CHAR) NOT NULL,
"TYPE_NAME" VARCHAR2(4000 CHAR) NOT NULL,
"NAME" VARCHAR2(4000 CHAR) NOT NULL,
"ACTION" VARCHAR2(4000 CHAR),
"ENABLED" VARCHAR2(8 CHAR),
"SEQ" NUMBER,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SCHEDULER_JOBS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"JOB_NAME" VARCHAR2(128 CHAR) NOT NULL,
"JOB_SUBNAME" VARCHAR2(128 CHAR),
"JOB_STYLE" VARCHAR2(17 CHAR),
"JOB_CREATOR" VARCHAR2(128 CHAR),
"CLIENT_ID" VARCHAR2(65 CHAR),
"GLOBAL_UID" VARCHAR2(33 CHAR),
"PROGRAM_OWNER" VARCHAR2(4000 CHAR),
"PROGRAM_NAME" VARCHAR2(4000 CHAR),
"JOB_TYPE" VARCHAR2(16 CHAR),
"JOB_ACTION" VARCHAR2(4000 CHAR),
"NUMBER_OF_ARGUMENTS" NUMBER,
"SCHEDULE_OWNER" VARCHAR2(4000 CHAR),
"SCHEDULE_NAME" VARCHAR2(4000 CHAR),
"SCHEDULE_TYPE" VARCHAR2(12 CHAR),
"START_DATE" TIMESTAMP (6) WITH TIME ZONE,
"REPEAT_INTERVAL" VARCHAR2(4000 CHAR),
"EVENT_QUEUE_OWNER" VARCHAR2(128 CHAR),
"EVENT_QUEUE_NAME" VARCHAR2(128 CHAR),
"EVENT_QUEUE_AGENT" VARCHAR2(523 CHAR),
"EVENT_CONDITION" VARCHAR2(4000 CHAR),
"EVENT_RULE" VARCHAR2(261 CHAR),
"FILE_WATCHER_OWNER" VARCHAR2(261 CHAR),
"FILE_WATCHER_NAME" VARCHAR2(261 CHAR),
"END_DATE" TIMESTAMP (6) WITH TIME ZONE,
"JOB_CLASS" VARCHAR2(128 CHAR),
"ENABLED" VARCHAR2(5 CHAR),
"AUTO_DROP" VARCHAR2(5 CHAR),
"RESTART_ON_RECOVERY" VARCHAR2(5 CHAR),
"RESTART_ON_FAILURE" VARCHAR2(5 CHAR),
"STATE" VARCHAR2(15 CHAR),
"JOB_PRIORITY" NUMBER,
"RUN_COUNT" NUMBER,
"UPTIME_RUN_COUNT" NUMBER,
"MAX_RUNS" NUMBER,
"FAILURE_COUNT" NUMBER,
"UPTIME_FAILURE_COUNT" NUMBER,
"MAX_FAILURES" NUMBER,
"RETRY_COUNT" NUMBER,
"LAST_START_DATE" TIMESTAMP (6) WITH TIME ZONE,
"LAST_RUN_DURATION" INTERVAL DAY (9) TO SECOND (6),
"NEXT_RUN_DATE" TIMESTAMP (6) WITH TIME ZONE,
"SCHEDULE_LIMIT" INTERVAL DAY (3) TO SECOND (0),
"MAX_RUN_DURATION" INTERVAL DAY (3) TO SECOND (0),
"LOGGING_LEVEL" VARCHAR2(11 CHAR),
"STORE_OUTPUT" VARCHAR2(5 CHAR),
"STOP_ON_WINDOW_CLOSE" VARCHAR2(5 CHAR),
"INSTANCE_STICKINESS" VARCHAR2(5 CHAR),
"RAISE_EVENTS" VARCHAR2(4000 CHAR),
"SYSTEM" VARCHAR2(5 CHAR),
"JOB_WEIGHT" NUMBER,
"NLS_ENV" VARCHAR2(4000 CHAR),
"SOURCE" VARCHAR2(128 CHAR),
"NUMBER_OF_DESTINATIONS" NUMBER,
"DESTINATION_OWNER" VARCHAR2(261 CHAR),
"DESTINATION" VARCHAR2(261 CHAR),
"CREDENTIAL_OWNER" VARCHAR2(128 CHAR),
"CREDENTIAL_NAME" VARCHAR2(128 CHAR),
"INSTANCE_ID" NUMBER,
"DEFERRED_DROP" VARCHAR2(5 CHAR),
"ALLOW_RUNS_IN_RESTRICTED_MODE" VARCHAR2(5 CHAR),
"COMMENTS" VARCHAR2(4000 CHAR),
"FLAGS" NUMBER,
"RESTARTABLE" VARCHAR2(5 CHAR),
"HAS_CONSTRAINTS" VARCHAR2(5 CHAR),
"CONNECT_CREDENTIAL_OWNER" VARCHAR2(128 CHAR),
"CONNECT_CREDENTIAL_NAME" VARCHAR2(128 CHAR),
"FAIL_ON_SCRIPT_ERROR" VARCHAR2(5 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_AUDIT_POLICIES"
(
"OBJECT_SCHEMA" VARCHAR2(128 CHAR),
"OBJECT_NAME" VARCHAR2(128 CHAR),
"POLICY_OWNER" VARCHAR2(128 CHAR),
"POLICY_NAME" VARCHAR2(128 CHAR),
"POLICY_TEXT" VARCHAR2(4000 CHAR),
"POLICY_COLUMN" VARCHAR2(128 CHAR),
"PF_SCHEMA" VARCHAR2(128 CHAR),
"PF_PACKAGE" VARCHAR2(128 CHAR),
"PF_FUNCTION" VARCHAR2(128 CHAR),
"ENABLED" VARCHAR2(3 CHAR),
"SEL" VARCHAR2(3 CHAR),
"INS" VARCHAR2(3 CHAR),
"UPD" VARCHAR2(3 CHAR),
"DEL" VARCHAR2(3 CHAR),
"AUDIT_TRAIL" VARCHAR2(12 CHAR),
"POLICY_COLUMN_OPTIONS" VARCHAR2(11 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SYS_PRIVS"
(
"GRANTEE" VARCHAR2(128 CHAR) NOT NULL,
"PRIVILEGE" VARCHAR2(40 CHAR) NOT NULL,
"ADMIN_OPTION" VARCHAR2(3 CHAR),
"COMMON" VARCHAR2(3 CHAR),
"INHERITED" VARCHAR2(3 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SYNONYMS"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"SYNONYM_NAME" VARCHAR2(128 CHAR) NOT NULL,
"TABLE_OWNER" VARCHAR2(128 CHAR),
"TABLE_NAME" VARCHAR2(128 CHAR),
"DB_LINK" VARCHAR2(128 CHAR),
"ORIGIN_CON_ID" NUMBER,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_HASH"
(
"OWNER" VARCHAR2(128 CHAR) NOT NULL,
"NAME" VARCHAR2(128 CHAR) NOT NULL,
"TYPE" VARCHAR2(12 CHAR) NOT NULL,
"ORIGIN_CON_ID" NUMBER,
"CON_ID" NUMBER,
"MD5_HASH" RAW(16) NOT NULL,
"SHA1_HASH" RAW(20) NOT NULL,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

COMMENT ON COLUMN T_HASH.MD5_HASH IS 'Join with DM_CODES on MD5_HASH column.';

CREATE TABLE "T_FILES"
(
"PATH" VARCHAR2(500 CHAR) NOT NULL,
"SHA256_HASH" RAW(32),
"FILE_TYPE"  VARCHAR2(1 CHAR) NOT NULL,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SYMBOLS"
(
"FILE_NAME" VARCHAR2(200 CHAR) NOT NULL,
"SYMBOL_TYPE" VARCHAR2(1 CHAR) NOT NULL,
"SYMBOL_NAME" VARCHAR2(500 CHAR),
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_TXTCOLLECTION"
(
"PATH" VARCHAR2(500 CHAR) NOT NULL,
"MD5_HASH" RAW(16),
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

COMMENT ON COLUMN T_TXTCOLLECTION.MD5_HASH IS 'Join with DM_CONTENTS on MD5_HASH column.';

CREATE TABLE "T_BUGSFIXED"
(
"BUG_ID" NUMBER NOT NULL,
"PATCH_ID" NUMBER NOT NULL,
"BUG_DESC" VARCHAR2(1000 CHAR) NOT NULL,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_ORAERR"
(
"ORAERR" NUMBER(5,0) NOT NULL,
"RESERVED" NUMBER, 
"MESSAGE" VARCHAR2(4000 CHAR), 
"CAUSE" VARCHAR2(4000 CHAR), 
"ACTION" VARCHAR2(4000 CHAR), 
"NOTE" VARCHAR2(4000 CHAR), 
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

CREATE TABLE "DM_CONTENTS"
(
"MD5_HASH" RAW(16) NOT NULL,
"CONTENTS" CLOB NOT NULL,
CONSTRAINT DM_CONTENTS_PK PRIMARY KEY ("MD5_HASH")
)
COMPRESS NOLOGGING;

CREATE TABLE "DM_CODES"
(
"MD5_HASH" RAW(16) NOT NULL,
"MD5_HASH_UNWRAPPED" RAW(16) NULL,
"CODE" CLOB NOT NULL,
"WRAPPED" VARCHAR2(1 CHAR) NOT NULL CHECK ("WRAPPED" IN ('Y','N')),
CONSTRAINT DM_CODES_PK PRIMARY KEY ("MD5_HASH"),
CONSTRAINT DM_CODES_FK FOREIGN KEY ("MD5_HASH") REFERENCES DM_CODES ("MD5_HASH")
)
COMPRESS NOLOGGING;

-----------------------------------------------------
-- Tables only for process logging
-- For the tables below, I don't remove any column
-----------------------------------------------------

-- select view_name from dba_views where view_name like 'CDB%REGISTRY%' order by 1;
-- SET LINES 10000 PAGES 10000 LONG 10000 LONGC 10000 TRIMS ON HEA OFF
-- EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
-- EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
-- EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
-- EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);
-- EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SIZE_BYTE_KEYWORD',true);
-- DROP TABLE T_REGISTRY;
-- CREATE TABLE T_REGISTRY AS SELECT * FROM CDB_REGISTRY;
-- SELECT DBMS_METADATA.GET_DDL('TABLE','T_REGISTRY') FROM DUAL;

CREATE TABLE "T_REGISTRY"
(
"COMP_ID" VARCHAR2(30 CHAR),
"COMP_NAME" VARCHAR2(255 CHAR),
"VERSION" VARCHAR2(30 CHAR),
"VERSION_FULL" VARCHAR2(30 CHAR),
"STATUS" VARCHAR2(44 CHAR),
"MODIFIED" VARCHAR2(29 CHAR),
"NAMESPACE" VARCHAR2(30 CHAR),
"CONTROL" VARCHAR2(128 CHAR),
"SCHEMA" VARCHAR2(128 CHAR),
"PROCEDURE" VARCHAR2(128 CHAR),
"STARTUP" VARCHAR2(8 CHAR),
"PARENT_ID" VARCHAR2(30 CHAR),
"OTHER_SCHEMAS" VARCHAR2(4000 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_BACKPORTS"
(
"BUGNO" NUMBER,
"VERSION_FULL" VARCHAR2(30 CHAR),
"COMP_ID" VARCHAR2(30 CHAR),
"NAMESPACE" VARCHAR2(30 CHAR),
"BACKPORT_TYPE" VARCHAR2(30 CHAR),
"BACKPORT_TIME" TIMESTAMP (6),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_DATABASE"
(
"PLATFORM_ID" NUMBER,
"PLATFORM_NAME" VARCHAR2(101 CHAR),
"EDITION" VARCHAR2(30 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_DEPENDENCIES"
(
"COMP_ID" VARCHAR2(30 CHAR),
"NAMESPACE" VARCHAR2(30 CHAR),
"REQ_COMP_ID" VARCHAR2(30 CHAR),
"REQ_NAMESPACE" VARCHAR2(30 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_ERROR"
(
"USERNAME" VARCHAR2(256 CHAR),
"TIMESTAMP" TIMESTAMP (6),
"SCRIPT" VARCHAR2(1024 CHAR),
"IDENTIFIER" VARCHAR2(256 CHAR),
"MESSAGE" CLOB,
"STATEMENT" CLOB,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_HIERARCHY"
(
"NAMESPACE" VARCHAR2(30 CHAR),
"COMP_ID" VARCHAR2(4000 CHAR),
"VERSION" VARCHAR2(30 CHAR),
"VERSION_FULL" VARCHAR2(30 CHAR),
"STATUS" VARCHAR2(44 CHAR),
"MODIFIED" VARCHAR2(29 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_HISTORY"
(
"ACTION_TIME" TIMESTAMP (6),
"ACTION" VARCHAR2(30 CHAR),
"NAMESPACE" VARCHAR2(30 CHAR),
"VERSION" VARCHAR2(30 CHAR),
"ID" NUMBER,
"COMMENTS" VARCHAR2(255 CHAR),
"BUNDLE_SERIES" VARCHAR2(30 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_LOG"
(
"OPTIME" TIMESTAMP (6),
"NAMESPACE" VARCHAR2(30 CHAR),
"COMP_ID" VARCHAR2(30 CHAR),
"OPERATION" VARCHAR2(11 CHAR),
"MESSAGE" VARCHAR2(1000 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_PROGRESS"
(
"COMP_ID" VARCHAR2(30 CHAR),
"NAMESPACE" VARCHAR2(30 CHAR),
"ACTION" VARCHAR2(255 CHAR),
"VALUE" VARCHAR2(255 CHAR),
"STEP" NUMBER,
"ACTION_TIME" TIMESTAMP (6),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_SCHEMAS"
(
"NAMESPACE" VARCHAR2(30 CHAR),
"COMP_ID" VARCHAR2(30 CHAR),
"SCHEMA" VARCHAR2(128 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_SQLPATCH"
(
"INSTALL_ID" NUMBER,
"PATCH_ID" NUMBER,
"PATCH_UID" NUMBER,
"PATCH_TYPE" VARCHAR2(10 CHAR),
"ACTION" VARCHAR2(15 CHAR),
"STATUS" VARCHAR2(25 CHAR),
"ACTION_TIME" TIMESTAMP (6),
"DESCRIPTION" VARCHAR2(100 CHAR),
"LOGFILE" VARCHAR2(500 CHAR),
"RU_LOGFILE" VARCHAR2(500 CHAR),
"FLAGS" VARCHAR2(10 CHAR),
--"PATCH_DESCRIPTOR" "SYS"."XMLTYPE" ,
--"PATCH_DIRECTORY" BLOB,
"SOURCE_VERSION" VARCHAR2(15 CHAR),
"SOURCE_BUILD_DESCRIPTION" VARCHAR2(80 CHAR),
"SOURCE_BUILD_TIMESTAMP" TIMESTAMP (6),
"TARGET_VERSION" VARCHAR2(15 CHAR),
"TARGET_BUILD_DESCRIPTION" VARCHAR2(80 CHAR),
"TARGET_BUILD_TIMESTAMP" TIMESTAMP (6),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_REGISTRY_SQLPATCH_RU_INFO"
(
"PATCH_ID" NUMBER,
"PATCH_UID" NUMBER,
--"PATCH_DESCRIPTOR" "SYS"."XMLTYPE" ,
"RU_VERSION" VARCHAR2(15 CHAR),
"RU_BUILD_DESCRIPTION" VARCHAR2(80 CHAR),
"RU_BUILD_TIMESTAMP" TIMESTAMP (6),
--"PATCH_DIRECTORY" BLOB,
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

CREATE TABLE "T_SERVER_REGISTRY"
(
"COMP_ID" VARCHAR2(30 CHAR),
"COMP_NAME" VARCHAR2(255 CHAR),
"VERSION" VARCHAR2(30 CHAR),
"VERSION_FULL" VARCHAR2(30 CHAR),
"STATUS" VARCHAR2(44 CHAR),
"MODIFIED" VARCHAR2(29 CHAR),
"CONTROL" VARCHAR2(128 CHAR),
"SCHEMA" VARCHAR2(128 CHAR),
"PROCEDURE" VARCHAR2(128 CHAR),
"STARTUP" VARCHAR2(8 CHAR),
"PARENT_ID" VARCHAR2(30 CHAR),
"OTHER_SCHEMAS" VARCHAR2(4000 CHAR),
"CON_ID" NUMBER,
"ORAVERSION" VARCHAR2(20 CHAR) NOT NULL,
"ORASERIES" VARCHAR2(10 CHAR) NOT NULL,
"ORAPATCH" NUMBER NOT NULL
)
COMPRESS NOLOGGING;

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------