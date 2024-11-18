DECLARE
  V_VERS_1D NUMBER := '&P_VERS_1D.';
  V_VERS_4D VARCHAR2(20) := '&P_VERS_4D.';
  V_USER    VARCHAR2(30) := '&&V_USERNAME.';

  PROCEDURE RUN_INSERT (P_TGT_TABLE VARCHAR2,
                        P_SRC_TABLE VARCHAR2,
                        P_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL,
                        P_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL,
                        P_WHERE_INT_FILTER VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS VARCHAR2(32767);
    V_INS_COLS VARCHAR2(32767);
    V_SQL VARCHAR2(32767); -- 10.2 does not support CLOB for EXECUTE IMMEDIATE
    V_OBJ_EXISTS NUMBER;
    V_CDB_CLAUSE VARCHAR2(30);
    V_WHERE_ADDED BOOLEAN := FALSE;

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
      V_CDB_CLAUSE := '';
    else
      V_CDB_CLAUSE := ', CON_ID';
    END IF;

    --  Bug 22168436  ORA-600 [kkdoilsn2] on select from CONTAINERS(...) -  Using BLOB / ANYDATA / XMLTYPE.

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
        where  c1.table_name = P_TGT_TABLE
        and    c2.table_name (+) = P_SRC_TABLE
        and    c1.owner = V_USER
        and    c2.owner(+) = 'SYS'
        and    c1.column_name = c2.column_name (+)
        and    c1.column_name not in ('CON_ID')
        order by c1.column_id
      );

    V_SQL := 'INSERT /*+ APPEND */ INTO ' || V_USER || '.' || P_TGT_TABLE || '(' || V_TAB_COLS || V_CDB_CLAUSE || ') SELECT ';

    V_SQL := V_SQL || V_INS_COLS || V_CDB_CLAUSE;

    IF V_VERS_1D <= 11 THEN
      V_SQL := V_SQL || ' FROM ' || P_SRC_TABLE;
    ELSIF V_VERS_4D = '12.1.0.1' THEN
      V_SQL := V_SQL || ' FROM CDB$VIEW("' || P_SRC_TABLE || '")';
    ELSE
      V_SQL := V_SQL || ' FROM CONTAINERS(' || P_SRC_TABLE || ')';
    END IF;

    IF V_VERS_1D <= 11 THEN
      IF P_WHERE_CLAUSE_11 IS NOT NULL THEN
        ADD_WHERE;
        V_SQL := V_SQL || '( ' || P_WHERE_CLAUSE_11 || ' )';
      END IF;
    ELSE
      IF P_WHERE_CLAUSE_12 IS NOT NULL THEN
        ADD_WHERE;
        V_SQL := V_SQL || '( ' || P_WHERE_CLAUSE_12 || ' )';
      END IF;
    END IF;

    IF '&v_internal' = 'true' AND P_WHERE_INT_FILTER IS NOT NULL THEN
      ADD_WHERE;
      V_SQL := V_SQL || '( ' || P_WHERE_INT_FILTER || ' )';
    END IF;

    SELECT COUNT(1)
    INTO   V_OBJ_EXISTS
    FROM   DBA_OBJECTS V1
    WHERE  V1.OWNER = 'SYS'
    AND    V1.OBJECT_NAME = P_SRC_TABLE
    AND    OBJECT_TYPE IN ('TABLE','VIEW');

    DBMS_OUTPUT.PUT_LINE('----------');
    IF V_OBJ_EXISTS = 1
    THEN
      DBMS_OUTPUT.PUT_LINE(V_SQL || ';');
      EXECUTE IMMEDIATE V_SQL;
    ELSE
      DBMS_OUTPUT.PUT_LINE(P_SRC_TABLE || ' does not exist.');
      V_SQL := 'DROP TABLE ' || V_USER || '.' || P_TGT_TABLE || ' PURGE';
      DBMS_OUTPUT.PUT_LINE(V_SQL || ';');
      EXECUTE IMMEDIATE V_SQL;
    END IF;

  END;
BEGIN
  DBMS_OUTPUT.ENABLE(NULL);

  RUN_INSERT ('T_AUDIT_UNIFIED_POLICIES',
              'AUDIT_UNIFIED_POLICIES',
              NULL,
              NULL,
              q'[OBJECT_SCHEMA = 'NONE' OR OBJECT_SCHEMA IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U')]'
             );
  RUN_INSERT ('T_AUD_UNIFIED_ENABLED_POLICIES','AUDIT_UNIFIED_ENABLED_POLICIES');
  RUN_INSERT ('T_AUD_UNIFIED_POLICY_COMMENTS','AUDIT_UNIFIED_POLICY_COMMENTS');
  RUN_INSERT ('T_OPTSTAT_HIST_CONTROL','OPTSTAT_HIST_CONTROL$');

END;
/