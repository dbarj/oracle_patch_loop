WHENEVER SQLERROR EXIT SQL.SQLCODE

-- TODO: CHANGE 2 QUERIES FOR 1 USING "INSERT ALL"

insert /*+ append */
  into &v_username..DM_CODES (MD5_HASH, CODE)
select MD5_HASH,
       CODE
from (
    select MD5_HASH,
           CODE,
           RANK() over (partition by MD5_HASH order by rowid asc) col_ind
    from &v_username..T_HASH_LOAD
)
where col_ind=1 and '&v_internal' = 'false';

DECLARE
  V_SQL VARCHAR2(32767); -- 10.2 does not support CLOB for EXECUTE IMMEDIATE
BEGIN
  IF '&v_internal' = 'true'
  THEN
    V_SQL := 'DROP TABLE &v_username.."DM_CODES" PURGE';
    DBMS_OUTPUT.PUT_LINE(V_SQL || ';');
    EXECUTE IMMEDIATE V_SQL;
  END IF;
END;
/

insert /*+ append */
  into &v_username..T_HASH (OWNER, NAME, TYPE, ORIGIN_CON_ID, CON_ID, MD5_HASH, SHA1_HASH)
select OWNER,
       NAME,
       TYPE,
       ORIGIN_CON_ID,
       CON_ID,
       MD5_HASH,
       SHA1_HASH
from &v_username..T_HASH_LOAD;

commit;

drop table &v_username..T_HASH_LOAD purge;

-- REMOVE_IF_ZIP_AFTER

-- This is no longer enabled after wrapper moved to PL/SQL

-- BEGIN - Added to avoid "Java not installed" errors.
-- WHENEVER SQLERROR CONTINUE
-- @@unwrap_code.sql
-- WHENEVER SQLERROR EXIT SQL.SQLCODE
-- END - Added to avoid "Java not installed" errors.