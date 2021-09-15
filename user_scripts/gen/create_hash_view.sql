alter session set current_schema=&&v_username.;

DECLARE
  VCODE CLOB;
  VVERS VARCHAR2(20) := '&&P_VERS.';
  VSER VARCHAR2(10) := '&&P_SER.';
  VPSU NUMBER := &&P_PSU.;
  VSID  VARCHAR2(30) := 'VIEW_TESTE';
    CURSOR OBJS IS
      SELECT OBJECT_OWNER OWNER,
             OBJECT_NAME NAME,
             OBJECT_TYPE TYPE,
             ID CON_ID,
             PARENT_ID ORIGIN_CON_ID,
             OTHER_XML TEXT
      FROM   PLAN_TABLE
      WHERE  STATEMENT_ID = VSID-- and rownum < 1000;
      ORDER  BY 1,2;
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
BEGIN
  $IF DBMS_DB_VERSION.VER_LE_11
  $THEN
  INSERT INTO PLAN_TABLE (STATEMENT_ID, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, ID, PARENT_ID, OTHER_XML)
  SELECT VSID,
         OWNER,
         VIEW_NAME,
         'VIEW',
         NULL CON_ID,
         NULL ORIGIN_CON_ID,
         TO_LOB(TEXT)
  FROM   DBA_VIEWS;
  $ELSE
  INSERT INTO PLAN_TABLE (STATEMENT_ID, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, ID, PARENT_ID, OTHER_XML)
  SELECT VSID,
         OWNER,
         VIEW_NAME,
         'VIEW',
         SYS_CONTEXT('USERENV','CON_ID') CON_ID,
         ORIGIN_CON_ID,
         TO_LOB(TEXT)
  FROM   DBA_VIEWS;

  INSERT INTO PLAN_TABLE (STATEMENT_ID, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE, ID, PARENT_ID, OTHER_XML)
  SELECT VSID,
         OWNER,
         VIEW_NAME,
         'VIEW',
         CON_ID,
         ORIGIN_CON_ID,
         TEXT_VC
  FROM   CDB_VIEWS
  WHERE  CON_ID <> SYS_CONTEXT('USERENV','CON_ID') -- AND CON_ID IN (1,2)
  AND    ORIGIN_CON_ID = CON_ID;
  $END
  FOR I IN OBJS
  LOOP
    VCODE := UPPER(I.TEXT);
    VCODE := replaceClob(VCODE,'[[:space:]]*',''); -- Remove all space characters
    VCODE := replaceClob(VCODE,'"',''); -- Remove all quotes
    INSERT INTO T_HASH (OWNER, NAME, TYPE, ORIGIN_CON_ID, CON_ID, MD5_HASH, SHA1_HASH, SERIES, ORAVERSION, PSU, CODE)
    VALUES
      (I.OWNER, I.NAME, I.TYPE, I.ORIGIN_CON_ID, I.CON_ID, SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_MD5), SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_SH1), VSER, VVERS, VPSU, I.TEXT);
	
  END LOOP;
  DELETE FROM PLAN_TABLE WHERE STATEMENT_ID = VSID;
END;
/