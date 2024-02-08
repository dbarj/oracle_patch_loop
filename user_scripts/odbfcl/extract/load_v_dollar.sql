DECLARE
  V_VERS_1D NUMBER := '&P_VERS_1D.';

  PROCEDURE RUN_INSERT (OUT_TAB_NAME VARCHAR2,
                        IN_TAB_NAME VARCHAR2,
                        IN_WHERE_CLAUSE_12 VARCHAR2 DEFAULT NULL,
                        IN_WHERE_CLAUSE_11 VARCHAR2 DEFAULT NULL)
  AS
    V_TAB_COLS CLOB;
    V_INS_COLS CLOB;
    V_SQL CLOB;
  BEGIN

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
      and    c1.column_name = c2.column_name (+);
    $END

    V_SQL := 'INSERT /*+ APPEND */ INTO &v_username..' || OUT_TAB_NAME || '(' || V_TAB_COLS || ') SELECT ';

    V_SQL := V_SQL || V_INS_COLS;

    V_SQL := V_SQL || ' FROM ' || IN_TAB_NAME;

    IF V_VERS_1D = 11 THEN
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

  RUN_INSERT ('T_OBSOLETE_PARAMETER','V_$OBSOLETE_PARAMETER');

  RUN_INSERT ('T_SQL_HINT','V_$SQL_HINT');

END;
/

commit;

-- Get Fixed View Definition full code

DECLARE
  l_clob CLOB;
  V_VERS_1D NUMBER := '&P_VERS_1D.';
BEGIN
  IF V_VERS_1D = 11 THEN
    RETURN;
  END IF;
  $IF NOT DBMS_DB_VERSION.VER_LE_11
  $THEN
    FOR I IN (select view_name from v_$fixed_view_definition t1 where length(t1.view_definition)=4000)
    LOOP
      DBMS_UTILITY.expand_sql_text (
        input_sql_text  => 'select * from ' || i.view_name,
        output_sql_text => l_clob
      );
      update &v_username..t_fixed_view_definition t1 set t1.view_definition_clob=l_clob where t1.view_name=i.view_name;
    END LOOP;
  $END
END;
/
