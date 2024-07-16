WHENEVER SQLERROR EXIT SQL.SQLCODE

-- TODO: CHANGE 2 QUERIES FOR 1 USING "INSERT ALL"

insert /*+ append */
  into &v_username..DM_CODES (MD5_HASH, CODE, WRAPPED)
select MD5_HASH,
       CODE,
       CASE
        WHEN REGEXP_INSTR(CODE, 'wrapped', 1, 1, 0, 'i') > 0
         AND REGEXP_INSTR(CODE, 'abcd', 1, 1, 0, 'i') > 0
        THEN 'Y'
        ELSE 'N'
        END WRAPPED
from (
    select MD5_HASH,
           CODE,
           RANK() over (partition by MD5_HASH order by rowid asc) col_ind
    from &v_username..T_HASH_LOAD
)
where col_ind=1;

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