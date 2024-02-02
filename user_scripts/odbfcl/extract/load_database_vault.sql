DECLARE
  V_VERS_1D NUMBER := '&P_VERS_1D.';
  V_VERS_4D VARCHAR2(20) := '&P_VERS_4D.';
  V_USER    VARCHAR2(30) := '&v_username.';

  PROCEDURE RUN_INSERT (IN_TAB_NAME VARCHAR2,
                       OUT_TAB_NAME VARCHAR2)
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

    select listagg(c1.column_name,', ') within group(order by c1.column_id),
           listagg(nvl(c2.column_name,'NULL'),', ') within group(order by c1.column_id)
    into   V_TAB_COLS, V_INS_COLS
    from   dba_tab_columns c1, dba_tab_columns c2
    where  c1.table_name = OUT_TAB_NAME
    and    c2.table_name (+) = IN_TAB_NAME
    and    c1.owner = V_USER
    and    c2.owner(+) = 'DVSYS'
    and    c1.column_name = c2.column_name (+)
    and    c1.column_name not in ('CON_ID');

    V_SQL := 'INSERT /*+ APPEND */ INTO ' || V_USER || '.' || OUT_TAB_NAME || '(' || V_TAB_COLS || V_CDB_CLAUSE || ') SELECT ';

    V_SQL := V_SQL || V_INS_COLS || V_CDB_CLAUSE;

    IF V_VERS_1D = 11 THEN
      V_SQL := V_SQL || ' FROM DVSYS.' || IN_TAB_NAME;
    ELSIF V_VERS_4D = '12.1.0.1' THEN
      V_SQL := V_SQL || ' FROM CDB$VIEW("DVSYS"."' || IN_TAB_NAME || '")';
    ELSE
      V_SQL := V_SQL || ' FROM CONTAINERS(DVSYS.' || IN_TAB_NAME || ')';
    END IF;

    DBMS_OUTPUT.PUT_LINE(V_SQL);
    EXECUTE IMMEDIATE V_SQL;

  END;
BEGIN
  DBMS_OUTPUT.ENABLE(NULL);

  RUN_INSERT ('DBA_DV_COMMAND_RULE','T_DV_COMMAND_RULE');
  RUN_INSERT ('DBA_DV_REALM','T_DV_REALM');
  RUN_INSERT ('DBA_DV_REALM_AUTH','T_DV_REALM_AUTH');
  RUN_INSERT ('DBA_DV_REALM_OBJECT','T_DV_REALM_OBJECT');
  RUN_INSERT ('DBA_DV_RULE','T_DV_RULE');
  RUN_INSERT ('DBA_DV_RULE_SET','T_DV_RULE_SET');

END;
/