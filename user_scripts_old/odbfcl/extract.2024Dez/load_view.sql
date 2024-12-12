DECLARE
  VCODE  CLOB;

  CURSOR OBJS IS
    SELECT OWNER, ROWID, CODE
    FROM   &v_username..T_HASH_LOAD
    WHERE  TYPE = 'VIEW';

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
  END replaceClob;
BEGIN

  $IF DBMS_DB_VERSION.VERSION <= 11
  $THEN
  INSERT INTO &v_username..T_HASH_LOAD (OWNER, NAME, TYPE, CON_ID, ORIGIN_CON_ID, CODE, MD5_HASH, SHA1_HASH)
  SELECT OWNER,
         VIEW_NAME,
         'VIEW',
         NULL CON_ID,
         NULL ORIGIN_CON_ID,
         TO_LOB(TEXT),
         '0',
         '0'
  FROM   DBA_VIEWS
  WHERE  (OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U') or '&v_internal' = 'false');
  $ELSE
  INSERT INTO &v_username..T_HASH_LOAD (OWNER, NAME, TYPE, CON_ID, ORIGIN_CON_ID, CODE, MD5_HASH, SHA1_HASH)
  SELECT OWNER,
         VIEW_NAME,
         'VIEW',
         SYS_CONTEXT('USERENV','CON_ID') CON_ID,
         ORIGIN_CON_ID,
         TO_LOB(TEXT),
         '0',
         '0'
  FROM   DBA_VIEWS
  WHERE  (OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U') or '&v_internal' = 'false');

  INSERT INTO &v_username..T_HASH_LOAD (OWNER, NAME, TYPE, CON_ID, ORIGIN_CON_ID, CODE, MD5_HASH, SHA1_HASH)
  SELECT OWNER,
         VIEW_NAME,
         'VIEW',
         CON_ID,
         ORIGIN_CON_ID,
         TEXT_VC,
         '0',
         '0'
  FROM   CDB_VIEWS
  WHERE  CON_ID <> SYS_CONTEXT('USERENV','CON_ID') -- AND CON_ID IN (1,2)
  AND    ORIGIN_CON_ID = CON_ID
  AND    (OWNER IN (SELECT NAME FROM &v_int_schema_tab. WHERE TYPE = 'U') or '&v_internal' = 'false');
  $END

  FOR I IN OBJS
  LOOP

    VCODE := UPPER(I.CODE);
    VCODE := replaceClob(VCODE,'[[:space:]]*',''); -- Remove all space characters
    VCODE := replaceClob(VCODE,'"',''); -- Remove all quotes
    UPDATE &v_username..T_HASH_LOAD
    SET MD5_HASH = SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_MD5),
       SHA1_HASH = SYS.DBMS_CRYPTO.HASH(VCODE, SYS.DBMS_CRYPTO.HASH_SH1)
    WHERE ROWID = I.ROWID;

  END LOOP;

END;
/