DECLARE
  VVERS VARCHAR2(20) := '&P_VERS.';
  VSER VARCHAR2(10) := '&P_SER.';
  VPATCH NUMBER := &P_PATCH.;

  PROCEDURE RUN_INSERT (IN_TAB_NAME VARCHAR2, OUT_TAB_NAME VARCHAR2, IN_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL, IN_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS CLOB;
    V_INS_COLS CLOB;
    V_SQL CLOB;
    V_CDB_CLAUSE VARCHAR2(30);
  BEGIN

    IF VVERS = '11.2.0.4' THEN
      V_CDB_CLAUSE := '';
    else
      V_CDB_CLAUSE := ', CON_ID';
    END IF;

    --  Bug 22168436  ORA-600 [kkdoilsn2] on select from CONTAINERS(...) -  Using BLOB / ANYDATA / XMLTYPE.

    select listagg(c1.column_name,', ') within group(order by c1.column_id),
           listagg(nvl(c2.column_name,'NULL'),', ') within group(order by c1.column_id)
    into   V_TAB_COLS, V_INS_COLS
    from   dba_tab_columns c1, dba_tab_columns c2
    where  c1.table_name = OUT_TAB_NAME
    and    c2.table_name (+) = IN_TAB_NAME
    and    c1.owner = '&v_username.'
    and    c2.owner(+) = 'SYS'
    and    c1.column_name = c2.column_name (+)
    and    c1.column_name not in ('CON_ID', 'ORASERIES', 'ORAVERSION', 'ORAPATCH');

    V_SQL := 'INSERT /*+ APPEND */ INTO &v_username..' || OUT_TAB_NAME || '(' || V_TAB_COLS || V_CDB_CLAUSE || ', ORAVERSION, ORASERIES, ORAPATCH) SELECT ';

    V_SQL := V_SQL || V_INS_COLS || V_CDB_CLAUSE || ', ' || SYS.DBMS_ASSERT.enquote_literal(VVERS) || ', ' || SYS.DBMS_ASSERT.enquote_literal(VSER) || ', ' || SYS.DBMS_ASSERT.enquote_literal(VPATCH);

    IF VVERS = '11.2.0.4' THEN
      V_SQL := V_SQL || ' FROM ' || IN_TAB_NAME;
    ELSIF VVERS = '12.1.0.1' THEN
      V_SQL := V_SQL || ' FROM CDB$VIEW("' || IN_TAB_NAME || '")';
    ELSE
      V_SQL := V_SQL || ' FROM CONTAINERS(' || IN_TAB_NAME || ')';
    END IF;

    IF VVERS = '11.2.0.4' THEN
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

  IF VVERS != '11.2.0.4' THEN
    RUN_INSERT ('AUDIT_UNIFIED_POLICIES','T_AUDIT_UNIFIED_POLICIES');
  END IF;

END;
/