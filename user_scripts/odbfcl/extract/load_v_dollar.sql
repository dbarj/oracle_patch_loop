DECLARE
  VVERS VARCHAR2(20) := '&P_VERS.';
  VSER VARCHAR2(10) := '&P_SER.';
  VPATCH NUMBER := &P_PATCH.;

  PROCEDURE RUN_INSERT (OUT_TAB_NAME VARCHAR2,
                        IN_TAB_NAME VARCHAR2,
                        IN_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL,
                        IN_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS CLOB;
    V_INS_COLS CLOB;
    V_SQL CLOB;
  BEGIN

    select listagg(c1.column_name,', ') within group(order by c1.column_id),
           listagg(nvl(c2.column_name,'NULL'),', ') within group(order by c1.column_id)
    into   V_TAB_COLS, V_INS_COLS
    from   dba_tab_columns c1, dba_tab_columns c2
    where  c1.table_name = OUT_TAB_NAME
    and    c2.table_name (+) = IN_TAB_NAME
    and    c1.owner = '&v_username.'
    and    c2.owner(+) = 'SYS'
    and    c1.column_name = c2.column_name (+)
    and    c1.column_name not in ('ORASERIES', 'ORAVERSION', 'ORAPATCH');

    V_SQL := 'INSERT /*+ APPEND */ INTO &v_username..' || OUT_TAB_NAME || '(' || V_TAB_COLS || ', ORAVERSION, ORASERIES, ORAPATCH) SELECT ';

    V_SQL := V_SQL || V_INS_COLS || ', ' || SYS.DBMS_ASSERT.enquote_literal(VVERS) || ', ' || SYS.DBMS_ASSERT.enquote_literal(VSER) || ', ' || SYS.DBMS_ASSERT.enquote_literal(VPATCH);

    V_SQL := V_SQL || ' FROM ' || IN_TAB_NAME;

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

  RUN_INSERT ('T_FIXED_TABLE','V_$FIXED_TABLE');

  RUN_INSERT ('T_FIXED_VIEW_DEFINITION','V_$FIXED_VIEW_DEFINITION');

  RUN_INSERT ('T_SYSSTAT','V_$SYSSTAT');

  RUN_INSERT ('T_SYS_TIME_MODEL','V_$SYS_TIME_MODEL');

  RUN_INSERT ('T_EVENT_NAME','V_$EVENT_NAME');

--  Those 2 tables will be loaded from X$ to include hidden parameters

--  RUN_INSERT ('T_PARAMETER','V_$PARAMETER');
--  RUN_INSERT ('T_PARAMETER_VALID_VALUES','V_$PARAMETER_VALID_VALUES');

  RUN_INSERT ('T_RESERVED_WORDS','V_$RESERVED_WORDS');

  RUN_INSERT ('T_SYSTEM_FIX_CONTROL','V_$SYSTEM_FIX_CONTROL');

END;
/