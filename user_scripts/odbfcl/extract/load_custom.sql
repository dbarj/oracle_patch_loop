DECLARE
  V_VERS_1D NUMBER := '&P_VERS_1D.';

  PROCEDURE RUN_INSERT (IN_TAB_NAME VARCHAR2, OUT_TAB_NAME VARCHAR2, IN_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL, IN_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS CLOB;
    V_INS_COLS CLOB;
    V_SQL CLOB;
    V_CDB_CLAUSE VARCHAR2(30);
  BEGIN

    IF V_VERS_1D = 11 THEN
      V_CDB_CLAUSE := '';
    else
      V_CDB_CLAUSE := ', CON_ID';
    END IF;

    --  Bug 22168436  ORA-600 [kkdoilsn2] on select from CONTAINERS(...) -  Using BLOB / ANYDATA / XMLTYPE.

    $IF DBMS_DB_VERSION.VER_LE_11_1
    $THEN
      select wm_concat(c1_column_name),
             wm_concat(c2_column_name)
        into v_tab_cols, v_ins_cols
        from (
          select c1.column_name c1_column_name,
                 nvl(c2.column_name,'NULL') c2_column_name
          from   dba_tab_columns c1, dba_tab_columns c2
          where  c1.table_name = OUT_TAB_NAME
          and    c2.table_name (+) = IN_TAB_NAME
          and    c1.owner = '&v_username.'
          and    c2.owner(+) = 'SYS'
          and    c1.column_name = c2.column_name (+)
          and    c1.column_name not in ('CON_ID')
          order by c1.column_id
        );
    $ELSE
      select listagg(c1.column_name,', ') within group(order by c1.column_id),
             listagg(nvl(c2.column_name,'NULL'),', ') within group(order by c1.column_id)
      into   V_TAB_COLS, V_INS_COLS
      from   dba_tab_columns c1, dba_tab_columns c2
      where  c1.table_name = OUT_TAB_NAME
      and    c2.table_name (+) = IN_TAB_NAME
      and    c1.owner = '&v_username.'
      and    c2.owner(+) = 'SYS'
      and    c1.column_name = c2.column_name (+)
      and    c1.column_name not in ('CON_ID');
    $END

    V_SQL := 'INSERT /*+ APPEND */ INTO &v_username..' || OUT_TAB_NAME || '(' || V_TAB_COLS || V_CDB_CLAUSE || ') SELECT ';

    V_SQL := V_SQL || V_INS_COLS || V_CDB_CLAUSE;

    IF V_VERS_1D = 11 THEN
      V_SQL := V_SQL || ' FROM ' || IN_TAB_NAME;
    ELSIF V_VERS_1D = '12.1.0.1' THEN
      V_SQL := V_SQL || ' FROM CDB$VIEW("' || IN_TAB_NAME || '")';
    ELSE
      V_SQL := V_SQL || ' FROM CONTAINERS(' || IN_TAB_NAME || ')';
    END IF;

    IF V_VERS_1D = 11 THEN
      IF IN_WHERE_CLAUSE_11 IS NOT NULL THEN
        V_SQL := V_SQL || ' WHERE ' || IN_WHERE_CLAUSE_11;
      END IF;
    ELSE
      IF IN_WHERE_CLAUSE_12 IS NOT NULL THEN
        V_SQL := V_SQL || ' WHERE ' || IN_WHERE_CLAUSE_12;
      END IF;
    END IF;

    DBMS_OUTPUT.PUT_LINE(V_SQL);
    EXECUTE IMMEDIATE V_SQL;

  END;
BEGIN
  DBMS_OUTPUT.ENABLE(NULL);

  IF V_VERS_1D != 11 THEN
    RUN_INSERT ('AUDIT_UNIFIED_POLICIES','T_AUDIT_UNIFIED_POLICIES');
    RUN_INSERT ('AUDIT_UNIFIED_ENABLED_POLICIES','T_AUD_UNIFIED_ENABLED_POLICIES');
    RUN_INSERT ('AUDIT_UNIFIED_POLICY_COMMENTS','T_AUD_UNIFIED_POLICY_COMMENTS');
  END IF;

  RUN_INSERT ('OPTSTAT_HIST_CONTROL$','T_OPTSTAT_HIST_CONTROL');

END;
/