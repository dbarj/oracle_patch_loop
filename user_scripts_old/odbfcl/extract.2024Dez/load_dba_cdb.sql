DECLARE
  V_VERS_1D NUMBER := '&&P_VERS_1D.';
  V_USER    VARCHAR2(30) := '&&V_USERNAME.';

  PROCEDURE RUN_INSERT (P_OBJ_SUFFIX VARCHAR2,
                        P_WHERE_CLAUSE_12  VARCHAR2 DEFAULT NULL,
                        P_WHERE_CLAUSE_11  VARCHAR2 DEFAULT NULL,
                        P_WHERE_INT_FILTER VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS VARCHAR2(32767);
    V_INS_COLS VARCHAR2(32767);
    V_SQL VARCHAR2(32767); -- 10.2 does not support CLOB for EXECUTE IMMEDIATE
    V_OBJ_EXISTS NUMBER;
    V_WHERE_ADDED BOOLEAN := FALSE;
    V_SRC_OBJECT VARCHAR2(100);
    V_TGT_TABLE VARCHAR2(100) := 'T_' || P_OBJ_SUFFIX;

    PROCEDURE ADD_WHERE IS
    BEGIN
      IF NOT V_WHERE_ADDED
      THEN
        V_SQL := V_SQL || ' WHERE ';
        V_WHERE_ADDED := TRUE;
      ELSE
        V_SQL := V_SQL || ' AND ';
      END IF;
    END ADD_WHERE;

  BEGIN
    IF V_VERS_1D <= 11 THEN
      V_SRC_OBJECT := 'DBA_' || P_OBJ_SUFFIX;
    else
      V_SRC_OBJECT := 'CDB_' || P_OBJ_SUFFIX;
    END IF;

    SELECT COUNT(1)
    INTO   V_OBJ_EXISTS
    FROM   DBA_VIEWS V1
    WHERE  V1.OWNER = 'SYS'
    AND    V1.VIEW_NAME = V_SRC_OBJECT;

    -- ORA-12805: parallel query server died unexpectedly
    -- ORA-00600: internal error code, arguments: [kkdlGetBaseUser2:authIdType], [0], [104], [_NEXT_USER], [], [], [], [], [], [], [], []
    -- Bug 22168436  ORA-600 [kkdoilsn2] on select from CONTAINERS(...) -  Using BLOB / ANYDATA / XMLTYPE. 

    $IF DBMS_DB_VERSION.VER_LE_10_2
    $THEN
    select wm_concat(c1_column_name),
           wm_concat(c2_column_name)
    $ELSIF DBMS_DB_VERSION.VER_LE_11_1
    $THEN
    select wm_concat(c1_column_name),
           wm_concat(c2_column_name)
    $ELSE
    select listagg(c1_column_name,', ') within group(order by column_id),
           listagg(c2_column_name,', ') within group(order by column_id)
    $END
      into v_tab_cols, v_ins_cols
      from (
        select c1.column_name c1_column_name,
               nvl(c2.column_name,'NULL') c2_column_name,
               c1.column_id
        from   dba_tab_columns c1, dba_tab_columns c2
        where  c1.owner = v_user
        and    c1.table_name = V_TGT_TABLE
        and    c2.owner(+) = 'SYS'
        and    c2.table_name (+) = V_SRC_OBJECT
        and    c1.column_name = c2.column_name (+)
        order by c1.column_id
      );

    V_SQL := 'INSERT /*+ APPEND */ INTO ' || V_USER || '.' || V_TGT_TABLE || '(' || V_TAB_COLS || ') SELECT ';

    V_SQL := V_SQL || V_INS_COLS;

    V_SQL := V_SQL || ' FROM ' || V_SRC_OBJECT;

    IF V_VERS_1D <= 11 THEN
      IF P_WHERE_CLAUSE_11 IS NOT NULL THEN
        ADD_WHERE;
        V_SQL := V_SQL || '( ' || P_WHERE_CLAUSE_11 || ' )';
      END IF;
    else
      IF P_WHERE_CLAUSE_12 IS NOT NULL THEN
        ADD_WHERE;
        V_SQL := V_SQL || '( ' || P_WHERE_CLAUSE_12 || ' )';
      END IF;
    END IF;

    IF '&v_internal' = 'true' AND P_WHERE_INT_FILTER IS NOT NULL THEN
      ADD_WHERE;
      V_SQL := V_SQL || '( ' || P_WHERE_INT_FILTER || ' )';
    END IF;

    DBMS_OUTPUT.PUT_LINE('----------');
    IF V_OBJ_EXISTS = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(V_SQL || ';');
      EXECUTE IMMEDIATE V_SQL;
    ELSE
      DBMS_OUTPUT.PUT_LINE(V_SRC_OBJECT || ' does not exist.');
      V_SQL := 'DROP TABLE ' || V_USER || '.' || V_TGT_TABLE || ' PURGE';
      DBMS_OUTPUT.PUT_LINE(V_SQL || ';');
      EXECUTE IMMEDIATE V_SQL;
    END IF;
    
  END;
BEGIN
  DBMS_OUTPUT.ENABLE(NULL);

  RUN_INSERT ('TAB_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.'
     AND NOT(TABLE_NAME LIKE '&&V_USERNAME.' AND PRIVILEGE='INHERIT PRIVILEGES')]',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','R','X'))
     AND OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')
     AND NOT (PRIVILEGE = 'INHERIT PRIVILEGES' AND TABLE_NAME NOT IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','X')))]'
  );

  RUN_INSERT ('COL_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','R','X'))
     AND OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('SYS_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','R','X'))]'
  );

  RUN_INSERT ('ROLE_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','R','X'))
     AND GRANTED_ROLE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('R','X'))]'
  );

  RUN_INSERT ('JAVA_POLICY',
  NULL,
  NULL,
  q'[GRANTEE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','R','X'))
     AND TYPE_SCHEMA IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('JOBS',
  NULL,
  NULL,
  q'[SCHEMA_USER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('TS_QUOTAS',
  q'[USERNAME != '&&V_USERNAME.']',
  q'[USERNAME != '&&V_USERNAME.']',
  q'[USERNAME IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('POLICIES',
  NULL,
  NULL,
  q'[OBJECT_OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('TRIGGERS',
  NULL,
  NULL,
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('SCHEDULER_JOBS',
  NULL,
  NULL,
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('SCHEDULER_PROGRAMS',
  NULL,
  NULL,
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('OBJ_AUDIT_OPTS',
  NULL,
  NULL,
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('STMT_AUDIT_OPTS',
  NULL,
  NULL,
  q'[USER_NAME IS NULL OR USER_NAME IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('PRIV_AUDIT_OPTS',
  NULL,
  NULL,
  q'[USER_NAME IS NULL OR USER_NAME IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('AUDIT_POLICIES',
  NULL,
  NULL,
  q'[OBJECT_SCHEMA IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')
     &skip_ver_le_10_s.
     AND POLICY_OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')
     &skip_ver_le_10_e.]'
  );

  RUN_INSERT ('AUDIT_POLICY_COLUMNS',
  NULL,
  NULL,
  q'[OBJECT_SCHEMA IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('DIRECTORIES',
  q'[DIRECTORY_NAME != '&&V_DIRECTORY.']',
  q'[DIRECTORY_NAME != '&&V_DIRECTORY.']',
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('PROCEDURES',
  NULL,
  NULL,
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('SYNONYMS',
  q'[ORIGIN_CON_ID=CON_ID]',
  NULL,
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','X'))
     AND (
      TABLE_OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U') OR
      (TABLE_OWNER = 'DVSYS' AND '&&P_VERS_4D.' = '11.2.0.4') OR
      (TABLE_OWNER = 'DBMS_PRIVILEGE_CAPTURE' AND '&&P_VERS_4D.' IN ('12.1.0.1','12.1.0.2'))
     )]'
  );

  RUN_INSERT ('USERS',
  q'[USERNAME != '&&V_USERNAME.']',
  q'[USERNAME != '&&V_USERNAME.']',
  q'[USERNAME IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('ROLES',
  NULL,
  NULL,
  q'[ROLE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'R')]'
  );

  RUN_INSERT ('PROFILES',
  NULL,
  NULL,
  q'[PROFILE IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'P')]'
  );

  RUN_INSERT ('OBJECTS',
  q'[OWNER != '&&V_USERNAME.' AND NOT (OWNER='SYS' AND OBJECT_NAME='&&V_DIRECTORY.' AND OBJECT_TYPE='DIRECTORY')]',
  q'[OWNER != '&&V_USERNAME.' AND NOT (OWNER='SYS' AND OBJECT_NAME='&&V_DIRECTORY.' AND OBJECT_TYPE='DIRECTORY')]',
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE IN ('U','X'))]'
  );

  RUN_INSERT ('TAB_COLUMNS',
  q'[OWNER != '&&V_USERNAME.']',
  q'[OWNER != '&&V_USERNAME.']',
  q'[OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
  );

  RUN_INSERT ('REGISTRY');
  RUN_INSERT ('REGISTRY_BACKPORTS');
  RUN_INSERT ('REGISTRY_DATABASE');
  RUN_INSERT ('REGISTRY_DEPENDENCIES');
  RUN_INSERT ('REGISTRY_ERROR');
  RUN_INSERT ('REGISTRY_HIERARCHY');
  RUN_INSERT ('REGISTRY_HISTORY');
  RUN_INSERT ('REGISTRY_LOG');
  RUN_INSERT ('REGISTRY_PROGRESS');
  RUN_INSERT ('REGISTRY_SCHEMAS');
  RUN_INSERT ('REGISTRY_SQLPATCH');
  RUN_INSERT ('REGISTRY_SQLPATCH_RU_INFO');
  RUN_INSERT ('SERVER_REGISTRY');

END;
/