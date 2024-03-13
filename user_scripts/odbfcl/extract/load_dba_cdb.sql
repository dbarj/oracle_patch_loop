DECLARE
  V_VERS_1D NUMBER := '&&P_VERS_1D.';
  V_USER    VARCHAR2(30) := '&&V_USERNAME.';

  PROCEDURE RUN_INSERT (IN_TAB_NAME VARCHAR2,
                        IN_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL,
                        IN_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS VARCHAR2(32767);
    V_INS_COLS VARCHAR2(32767);
    V_PREFIX VARCHAR2(4);
    V_SQL VARCHAR2(32767); -- 10.2 does not support CLOB for EXECUTE IMMEDIATE
    V_OBJ_EXISTS NUMBER;
  BEGIN
    IF V_VERS_1D <= 11 THEN
      V_PREFIX := 'DBA_';
    else
      V_PREFIX := 'CDB_';
    END IF;

    SELECT COUNT(1)
    INTO   V_OBJ_EXISTS
    FROM   DBA_VIEWS V1
    WHERE  V1.OWNER = 'SYS'
    AND    V1.VIEW_NAME = V_PREFIX || IN_TAB_NAME;

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
        where  c1.table_name = 'T_' || in_tab_name
        and    c2.table_name (+) = v_prefix || in_tab_name
        and    c1.owner = v_user
        and    c2.owner(+) = 'SYS'
        and    c1.column_name = c2.column_name (+)
        order by c1.column_id
      );

    V_SQL := 'INSERT /*+ APPEND */ INTO ' || V_USER || '.T_' || IN_TAB_NAME || '(' || V_TAB_COLS || ') SELECT ';

    V_SQL := V_SQL || V_INS_COLS;

    V_SQL := V_SQL || ' FROM ' || V_PREFIX || IN_TAB_NAME;

    IF V_VERS_1D <= 11 THEN
      IF IN_WHERE_CLAUSE_11 IS NOT NULL THEN
        V_SQL := V_SQL || ' WHERE ' || IN_WHERE_CLAUSE_11;
      END IF;
    else
      IF IN_WHERE_CLAUSE_12 IS NOT NULL THEN
        V_SQL := V_SQL || ' WHERE ' || IN_WHERE_CLAUSE_12;
      END IF;
    END IF;

    IF V_OBJ_EXISTS = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(V_SQL);
      EXECUTE IMMEDIATE V_SQL;
    ELSE
      DBMS_OUTPUT.PUT_LINE(V_PREFIX || IN_TAB_NAME || ' does not exist.');
    END IF;
    
  END;
BEGIN
  DBMS_OUTPUT.ENABLE(NULL);

  RUN_INSERT ('TAB_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.' AND NOT(TABLE_NAME LIKE '&&V_USERNAME.' AND PRIVILEGE='INHERIT PRIVILEGES')]',
  q'[GRANTEE != '&&V_USERNAME.']'
  );
  RUN_INSERT ('COL_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE != '&&V_USERNAME.']'
  );
  RUN_INSERT ('SYS_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE != '&&V_USERNAME.']'
  );
  RUN_INSERT ('ROLE_PRIVS',
  q'[GRANTEE != '&&V_USERNAME.']',
  q'[GRANTEE != '&&V_USERNAME.']'
  );

  RUN_INSERT ('JAVA_POLICY');

  RUN_INSERT ('JOBS');

  RUN_INSERT ('TS_QUOTAS',
  q'[USERNAME != '&&V_USERNAME.']',
  q'[USERNAME != '&&V_USERNAME.']'
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

  RUN_INSERT ('DIRECTORIES',
  q'[DIRECTORY_NAME != '&&V_DIRECTORY.']',
  q'[DIRECTORY_NAME != '&&V_DIRECTORY.']'
  );

  RUN_INSERT ('PROCEDURES');

  RUN_INSERT ('SYNONYMS',
  q'[ORIGIN_CON_ID=CON_ID]',
  NULL
  );

  RUN_INSERT ('USERS',
  q'[USERNAME != '&&V_USERNAME.']',
  q'[USERNAME != '&&V_USERNAME.']'
  );

  RUN_INSERT ('ROLES');

  RUN_INSERT ('OBJECTS',
  q'[OWNER != '&&V_USERNAME.' AND NOT (OWNER='SYS' AND OBJECT_NAME='&&V_DIRECTORY.' AND OBJECT_TYPE='DIRECTORY')]',
  q'[OWNER != '&&V_USERNAME.' AND NOT (OWNER='SYS' AND OBJECT_NAME='&&V_DIRECTORY.' AND OBJECT_TYPE='DIRECTORY')]'
  );

  RUN_INSERT ('TAB_COLUMNS',
  q'[OWNER != '&&V_USERNAME.']',
  q'[OWNER != '&&V_USERNAME.']'
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