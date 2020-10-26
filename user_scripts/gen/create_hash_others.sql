alter session set current_schema=&&v_username.;

DECLARE
  VVERS VARCHAR2(20) := '&&P_VERS.';
  VSER VARCHAR2(10) := '&&P_SER.';
  VPSU NUMBER := &&P_PSU.;
  VCUSTOMSTR  VARCHAR2(4000);

  PROCEDURE RUN_INSERT (IN_TAB_NAME VARCHAR2, IN_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL, IN_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS CLOB;
    V_INS_COLS CLOB;
    V_PREFIX VARCHAR2(4);
    V_SQL CLOB;
  BEGIN
    IF VVERS = '11.2.0.4' THEN
      V_PREFIX := 'DBA_';
    else
      V_PREFIX := 'CDB_';
    END IF;

    -- ORA-12805: parallel query server died unexpectedly
    -- ORA-00600: internal error code, arguments: [kkdlGetBaseUser2:authIdType], [0], [104], [_NEXT_USER], [], [], [], [], [], [], [], []
    -- Bug 22168436  ORA-600 [kkdoilsn2] on select from CONTAINERS(...) -  Using BLOB / ANYDATA / XMLTYPE.
    IF VVERS in ('12.1.0.2','12.2.0.1') AND IN_TAB_NAME = 'REGISTRY_SQLPATCH'
    THEN
      select listagg(c1.column_name,', ') within group(order by c1.column_id),
             listagg(nvl(c2.column_name,'NULL'),', ') within group(order by c1.column_id)
      into   V_TAB_COLS, V_INS_COLS
      from   dba_tab_columns c1, dba_tab_columns c2
      where  c1.table_name = 'T_' || IN_TAB_NAME
      and    c2.table_name (+) = V_PREFIX || IN_TAB_NAME
      and    c1.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
      and    c2.owner(+) = 'SYS'
      and    c1.column_name = c2.column_name (+)
      and    c2.data_type(+) not in ('XMLTYPE','CLOB','BLOB')
      and    c1.column_name not in ('SERIES', 'ORAVERSION', 'PSU');
    ELSE
      select listagg(c1.column_name,', ') within group(order by c1.column_id),
             listagg(nvl(c2.column_name,'NULL'),', ') within group(order by c1.column_id)
      into   V_TAB_COLS, V_INS_COLS
      from   dba_tab_columns c1, dba_tab_columns c2
      where  c1.table_name = 'T_' || IN_TAB_NAME
      and    c2.table_name (+) = V_PREFIX || IN_TAB_NAME
      and    c1.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
      and    c2.owner(+) = 'SYS'
      and    c1.column_name = c2.column_name (+)
      and    c1.column_name not in ('SERIES', 'ORAVERSION', 'PSU');
    END IF;

    V_SQL := 'INSERT /*+ APPEND */ INTO T_' || IN_TAB_NAME || '(' || V_TAB_COLS || ', SERIES, ORAVERSION, PSU) SELECT ';

    V_SQL := V_SQL || V_INS_COLS || ', ' || SYS.DBMS_ASSERT.enquote_literal(VSER) || ', ' || SYS.DBMS_ASSERT.enquote_literal(VVERS) || ', ' || SYS.DBMS_ASSERT.enquote_literal(VPSU);

    V_SQL := V_SQL || ' FROM ' || V_PREFIX || IN_TAB_NAME;

    IF VVERS = '11.2.0.4' THEN
      IF IN_WHERE_CLAUSE_11 IS NOT NULL THEN
        V_SQL := V_SQL || ' WHERE ' || IN_WHERE_CLAUSE_11;
      END IF;
    else
      IF IN_WHERE_CLAUSE_12 IS NOT NULL THEN
        V_SQL := V_SQL || ' WHERE ' || IN_WHERE_CLAUSE_12;
      END IF;
    END IF;
    DBMS_OUTPUT.PUT_LINE(V_SQL);

    EXECUTE IMMEDIATE V_SQL;
  END;
BEGIN
  DBMS_OUTPUT.ENABLE(NULL);

  RUN_INSERT ('TAB_PRIVS',
  q'[GRANTEE NOT LIKE 'C##%' AND NOT(TABLE_NAME LIKE 'C##%' AND PRIVILEGE='INHERIT PRIVILEGES')]',
  q'[GRANTEE NOT IN ('DBA_DVOWNER','DBA_DVACCTMGR','HASH')]'
  );
  RUN_INSERT ('COL_PRIVS',
  q'[GRANTEE NOT LIKE 'C##%']',
  q'[GRANTEE NOT IN ('DBA_DVOWNER','DBA_DVACCTMGR','HASH')]'
  );
  RUN_INSERT ('SYS_PRIVS',
  q'[GRANTEE NOT LIKE 'C##%']',
  q'[GRANTEE NOT IN ('DBA_DVOWNER','DBA_DVACCTMGR','HASH')]'
  );
  RUN_INSERT ('ROLE_PRIVS',
  q'[GRANTEE NOT LIKE 'C##%' AND GRANTEE NOT IN ('PDBADMIN','PDB_DBA')]',
  q'[GRANTEE NOT IN ('DBA_DVOWNER','DBA_DVACCTMGR','HASH')]'
  );

  RUN_INSERT ('JAVA_POLICY');

  RUN_INSERT ('JOBS');

  RUN_INSERT ('TS_QUOTAS',
  q'[USERNAME NOT LIKE 'C##%']',
  q'[USERNAME NOT IN ('HASH')]'
  );

  RUN_INSERT ('POLICIES');

  RUN_INSERT ('TRIGGERS');

  RUN_INSERT ('SCHEDULER_JOBS');

  RUN_INSERT ('SCHEDULER_PROGRAMS');

  RUN_INSERT ('OBJ_AUDIT_OPTS');

  RUN_INSERT ('STMT_AUDIT_OPTS');

  RUN_INSERT ('PRIV_AUDIT_OPTS');

  RUN_INSERT ('AUDIT_POLICIES');

  RUN_INSERT ('AUDIT_POLICY_COLUMNS');

  RUN_INSERT ('SYNONYMS',
  q'[ORIGIN_CON_ID=CON_ID]',
  NULL
  );

  RUN_INSERT ('REGISTRY_HISTORY');

  IF VVERS != '11.2.0.4' THEN
    RUN_INSERT ('REGISTRY_SQLPATCH');
  END IF;

END;
/