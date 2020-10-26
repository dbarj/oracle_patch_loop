whenever sqlerror exit sql.sqlcode
set verify off

BEGIN EXECUTE IMMEDIATE 'ALTER TABLE T_HASH_F ADD (NAME_COMP VARCHAR2(128))'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

UPDATE T_HASH_F SET NAME_COMP = NAME;
COMMIT;

BEGIN EXECUTE IMMEDIATE 'ALTER TABLE T_HASH_F MODIFY NAME_COMP NOT NULL'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
  TYPE v_array_skip IS TABLE OF VARCHAR2(200);

  ar_remove_lib_path v_array_skip := v_array_skip(
    --11g
    'SYS;DBMS_SUMADV_LIB;LIBRARY;',
    'ORDSYS;ORDIMLIBS;LIBRARY;',
    --12c
    'SYS;DBMS_SUMADV_LIB;LIBRARY;',
    'ORDSYS;ORDIMLIBS;LIBRARY;'
  );

  ar_remove_line_feed v_array_skip := v_array_skip(
    --11g
    'SYS;dbFWTrace;JAVA SOURCE;',
    'SYS;schedFileWatcherJava;JAVA SOURCE;',
    --12c
    'SYS;dbFWTrace;JAVA SOURCE;',
    'SYS;schedFileWatcherJava;JAVA SOURCE;'
  );

  ar_remove_hex_string v_array_skip := v_array_skip(
    --12c
    'SYS;WWV_FLOW_KEY;PACKAGE;'
  );

  VCODE CLOB;
  VNAME VARCHAR2(128);

  FUNCTION fc_remove_hex_string (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'''([[:digit:]]|[A-F])*''',''''''); -- Remove random HEX code between single quotes
  end;
  FUNCTION fc_remove_lib_path (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'''(.*)(/lib/[^/]*)''','''\2'''); -- Keep only the path after last "lib" folder
  end;
  FUNCTION fc_remove_line_feed (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,CHR(10),''); -- Remove line feed
  end;
  FUNCTION fc_remove_digits (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'[[:digit:]]+',''); -- Remove digits
  end;
  FUNCTION fc_adapt_type (V_STR_IN IN VARCHAR2) RETURN VARCHAR2 IS
     V_FINAL_PART varchar2(30);
  begin
     -- Ira truncar o código até o início da parte de dígito em X casas e concatenar o restante, variando o tamanho de acordo com o tamanho da própria string final e qtd de dígitos.
     -- Ex: PERFORMED_PROCEDURE_STE123_T -> PERFORMED_PROCEDURE123_T (24) | PREDICATES_DEFINITIO499_COLL -> PREDICATES_DEFIN499_COLL (24) | MEDIA_STORAGE_SOP_INSTA88_T -> MEDIA_STORAGE_SOP_I88_T (23)
     IF LENGTH(V_STR_IN)>23 THEN
       V_FINAL_PART := REGEXP_SUBSTR(V_STR_IN,'[[:digit:]]+_(T|COLL)$');
       RETURN SUBSTR(V_STR_IN,1,LEAST(24-(3-LENGTH(SUBSTR(V_FINAL_PART,1,INSTR(V_FINAL_PART,'_')-1))),LENGTH(V_STR_IN))-LENGTH(V_FINAL_PART)) || V_FINAL_PART;
     ELSE
       RETURN V_STR_IN;
     END IF;
  end;
  FUNCTION fc_remove_type_name_from_code (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'"([[:alpha:]]|_|-)+[[:digit:]]+_(T|COLL)"',''); -- Remove type name from code
  end;
  FUNCTION fc_remove_varwnum_from_code (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'"[[:graph:]]*[[:digit:]]+[[:graph:]]*"','""'); -- Remove string with digits between ""
  end;
  FUNCTION fc_remove_strwnum_from_code (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'''[[:graph:]]*[[:digit:]]+[[:graph:]]*''',''''''); -- Remove string with digits between ''
  end;
  -- [[:graph:]] should be replaced by [A-Z][a-z][0-9]_$+=#
BEGIN
  FOR I IN (SELECT T_HASH_F.ROWID,T_HASH_F.*,T2.CODE REALCODE FROM T_HASH_F, (SELECT SHA1_ENC, CODE, RANK() OVER(PARTITION BY SHA1_ENC ORDER BY ROWID ASC) LIN FROM T_HASH) T2 WHERE T_HASH_F.SHA1_ENC = T2.SHA1_ENC AND T2.LIN=1
            AND T_HASH_F.TYPE <> 'VIEW')
  LOOP
    VCODE := I.REALCODE; -- Zera a variável
    VNAME := I.NAME;
    -- BEGIN - Alter some codes
    IF I.OWNER || ';' || I.NAME || ';' || I.TYPE || ';' MEMBER OF ar_remove_lib_path THEN
      VCODE := fc_remove_lib_path(VCODE);
    END IF;
    IF I.OWNER || ';' || I.NAME || ';' || I.TYPE || ';' MEMBER OF ar_remove_line_feed THEN
      VCODE := fc_remove_line_feed(VCODE);
    END IF;
    IF I.OWNER || ';' || I.NAME || ';' || I.TYPE || ';' MEMBER OF ar_remove_hex_string THEN
      VCODE := fc_remove_hex_string(VCODE);
    END IF;

    IF I.OWNER IN ('MDSYS','XDB')  AND REGEXP_LIKE(I.NAME,'\$xd$') AND I.TYPE = 'TRIGGER' THEN
      VCODE := fc_remove_hex_string(VCODE);
    END IF;

    IF I.OWNER IN ('MDSYS','XDB')  AND REGEXP_LIKE(I.NAME,'_TAB\$xd$') AND I.TYPE = 'TRIGGER' THEN
      VNAME := fc_remove_digits(VNAME);
      VCODE := fc_remove_varwnum_from_code(VCODE);
      VCODE := fc_remove_strwnum_from_code(VCODE);
    END IF;

    -- Remove IDs from some TYPEs
    IF I.OWNER IN ('MDSYS','ORDSYS','SYS','XDB') AND REGEXP_LIKE(I.NAME,'^([[:alpha:]]|_|-)+[[:digit:]]+_(T|COLL)$') AND I.TYPE = 'TYPE' THEN
      VCODE := fc_remove_varwnum_from_code(VCODE);
      VNAME := fc_remove_digits(fc_adapt_type(VNAME));
    END IF;
    -- IF I.OWNER = 'ORDSYS' AND REGEXP_LIKE(I.NAME,'^([[:alpha:]]|_|-)+[[:digit:]]+_(T|COLL)$') AND I.TYPE = 'TYPE' THEN
    --   VCODE := fc_remove_varwnum_from_code(VCODE);
    -- END IF;
    IF I.OWNER IN ('SYS','DVSYS') AND REGEXP_LIKE(I.NAME,'^SYS_YOID([[:digit:]])*\$') AND I.TYPE = 'TYPE' THEN
      VCODE := fc_remove_varwnum_from_code(VCODE);
      VNAME := fc_remove_digits(VNAME);
    END IF;
    IF I.OWNER = 'SYS' AND REGEXP_LIKE(I.NAME,'^SYST.*==$') AND I.TYPE = 'TYPE' THEN
      VCODE := fc_remove_varwnum_from_code(VCODE);
      VNAME := REGEXP_REPLACE(VNAME,'^SYST.*==$','SYST==');
    END IF;

    IF VCODE <> I.REALCODE THEN
      UPDATE T_HASH_F
      SET MD5_ENC = SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_MD5),
         SHA1_ENC = SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_SH1)
      WHERE ROWID = I.ROWID;
    END IF;
    IF VNAME <> I.NAME THEN
      UPDATE T_HASH_F
      SET NAME_COMP = VNAME
      WHERE ROWID = I.ROWID;
    END IF;
  END LOOP;
  COMMIT;
END;
/

DECLARE
  VCODE CLOB;
  VREALCODE CLOB;
  VNAME VARCHAR2(30);

  TYPE v_array_skip IS TABLE OF VARCHAR2(200);

  ar_remove_qtobjno_string v_array_skip := v_array_skip(
    --12c
    'GSMADMIN_INTERNAL;AQ$CHANGE_LOG_QUEUE_TABLE;VIEW;',
    'SYS;AQ$ALERT_QT;VIEW;',
    'SYS;AQ$AQ$_MEM_MC;VIEW;',
    'SYS;AQ$AQ_PROP_TABLE;VIEW;',
    'SYS;AQ$SCHEDULER$_REMDB_JOBQTAB;VIEW;',
    'SYS;AQ$SCHEDULER_FILEWATCHER_QT;VIEW;',
    'SYS;AQ$SYS$SERVICE_METRICS_TAB;VIEW;',
    'WMSYS;AQ$WM$EVENT_QUEUE_TABLE;VIEW;',
    'SYS;AQ$SCHEDULER$_EVENT_QTAB;VIEW;'
  );

   FUNCTION replaceClob
     ( srcClob IN CLOB,
       replaceStr IN varchar2,
       replaceWith IN varchar2 )
   RETURN CLOB
   IS
     l_buffer VARCHAR2 (32767);
     l_amount BINARY_INTEGER := 32767;
     l_pos INTEGER := 1;
     l_clob_len INTEGER;
	 newClob clob := EMPTY_CLOB;
   BEGIN
     -- initalize the new clob
     dbms_lob.CreateTemporary( newClob, TRUE );
	 l_clob_len := DBMS_LOB.getlength (srcClob);
     WHILE l_pos <= l_clob_len
     LOOP
         DBMS_LOB.READ (srcClob,l_amount,l_pos,l_buffer);
         IF l_buffer IS NOT NULL
         THEN
		   -- replace the text
		   l_buffer := regexp_replace(l_buffer,replaceStr,replaceWith);
		   -- write it to the new clob
	       DBMS_LOB.writeAppend(newClob, LENGTH(l_buffer), l_buffer);
         END IF;
         l_pos :=   l_pos + l_amount;
     END LOOP;
	 RETURN newClob;
   END;
  FUNCTION fc_remove_digits (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'[[:digit:]]+',''); -- Remove digits
  end;
  FUNCTION fc_remove_qtobjno_string (V_STR_IN IN CLOB) RETURN CLOB IS
  begin
     RETURN REGEXP_REPLACE(V_STR_IN,'QTOBJNO=[[:digit:]]*','QTOBJNO='); -- Remove random HEX code between single quotes
  end;

BEGIN
  FOR I IN (SELECT T_HASH_F.ROWID,T_HASH_F.*,T2.CODE REALCODE FROM T_HASH_F, (SELECT SHA1_ENC, CODE, RANK() OVER(PARTITION BY SHA1_ENC ORDER BY ROWID ASC) LIN FROM T_HASH) T2 WHERE T_HASH_F.SHA1_ENC = T2.SHA1_ENC AND T2.LIN=1
            AND T_HASH_F.TYPE = 'VIEW')
  LOOP
    VREALCODE := UPPER(I.REALCODE);
    VREALCODE := replaceClob(VREALCODE,'[[:space:]]*',''); -- Remove all space characters
    VREALCODE := replaceClob(VREALCODE,'"',''); -- Remove all quotes
    VCODE := VREALCODE;
    VNAME := I.NAME;
    -- BEGIN - Alter some codes
    IF I.OWNER || ';' || I.NAME || ';' || I.TYPE || ';' MEMBER OF ar_remove_qtobjno_string THEN
      VCODE := fc_remove_qtobjno_string(VCODE);
    END IF;
    IF I.OWNER IN ('SYS') AND REGEXP_LIKE(I.NAME,'^QT([[:digit:]])*_BUFFER$') AND I.TYPE = 'VIEW' THEN
      VCODE := fc_remove_digits(VCODE); -- Verificar se isso é realmente necessário
      VNAME := fc_remove_digits(VNAME);
    END IF;
	
    IF VCODE <> VREALCODE THEN
      UPDATE T_HASH_F
      SET MD5_ENC = SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_MD5),
         SHA1_ENC = SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_SH1)
      WHERE ROWID = I.ROWID;
    END IF;
    IF VNAME <> I.NAME THEN
      UPDATE T_HASH_F
      SET NAME_COMP = VNAME
      WHERE ROWID = I.ROWID;
    END IF;
  END LOOP;
  COMMIT;
END;
/

whenever sqlerror continue
set verify on
