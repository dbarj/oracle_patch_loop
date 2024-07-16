-- Run diff generation process for ALL every database.
WHENEVER SQLERROR EXIT SQL.SQLCODE

DEF V_CONN            = '&1'
DEF V_BRELEASE        = '&2'

DEF V_TABLE_NAME_CODES    = 'DIFF_CODES_LOAD_&&V_BRELEASE.'
DEF V_TABLE_NAME_CONTENTS = 'DIFF_CONTENTS_LOAD_&&V_BRELEASE.'

SET TERMOUT OFF ECHO OFF

set define '^'
SPO get_code.sql
PRO set pages 0
PRO set long 1000000
PRO set lines 10000
PRO set trims on
PRO set feed off
PRO set echo off
PRO set verify off
PRO set define '&'
PRO col code for a10000
PRO set termout off
PRO spool &1..sql
PRO select code from dm_codes where md5_hash='&1';;
PRO spool off
SPO OFF
set define '&'

set define '^'
SPO get_contents.sql
PRO set pages 0
PRO set long 1000000
PRO set lines 10000
PRO set trims on
PRO set feed off
PRO set echo off
PRO set verify off
PRO set define '&'
PRO col code for a10000
PRO set termout off
PRO spool &1..sql
PRO select contents from dm_contents where md5_hash='&1';;
PRO spool off
SPO OFF
set define '&'

SPO gen_diff.sh
PRO set -eo pipefail
PRO v_type="$1"
PRO v_file_1="$2"
PRO v_file_2="$3"
PRO
PRO v_size=$(diff -t -bB "${v_file_1}.sql" "${v_file_2}.sql" | awk '{ print length }' | sort -n | tail -1)
PRO
PRO # -2 to remove '> ' or '< '
PRO # +3 to include ' | '
PRO if [ -z ${v_size} ]
PRO then
PRO   touch "${v_file_1}_${v_file_2}.txt"
PRO   exit 0
PRO fi
PRO v_size=$(((v_size-2)*2+3))
PRO
PRO sdiff -w ${v_size} -bB -t -l "${v_file_1}.sql" "${v_file_2}.sql" | cat -n | grep -v -e '($' > "${v_file_1}_${v_file_2}.${v_type}.txt"
SPO OFF

SPO load_codes.sh
PRO set -eo pipefail
PRO
PRO v_outpref="./list"
PRO v_file="${v_outpref}.csv"
PRO
PRO if ! ls *_*.codes.txt >/dev/null 2>/dev/null
PRO then
PRO   echo "Codes: no file to process."
PRO   exit 0
PRO fi
PRO
PRO ls -1 *_*.codes.txt > "${v_file}"
PRO
PRO cat << EOF > "${v_outpref}_load.ctl"
PRO LOAD
PRO INTO TABLE &&V_TABLE_NAME_CODES.
PRO APPEND
PRO FIELDS TERMINATED BY ','
PRO (file_name,
PRO  contents lobfile(file_name) terminated by eof)
PRO EOF
PRO
PRO sqlldr &V_CONN \
PRO control="${v_outpref}_load.ctl" \
PRO errors=0 \
PRO discardmax=0 \
PRO direct=Y \
PRO data="${v_file}" \
PRO log="${v_outpref}_load.log"
PRO
PRO rm -f "${v_outpref}_load.log" "${v_outpref}_load.ctl" "${v_file}"
SPO OFF

SPO load_contents.sh
PRO set -eo pipefail
PRO
PRO v_outpref="./list"
PRO v_file="${v_outpref}.csv"
PRO
PRO if ! ls *_*.contents.txt >/dev/null 2>/dev/null
PRO then
PRO   echo "Contents: no file to process."
PRO   exit 0
PRO fi
PRO
PRO ls -1 *_*.contents.txt > "${v_file}"
PRO
PRO cat << EOF > "${v_outpref}_load.ctl"
PRO LOAD
PRO INTO TABLE &&V_TABLE_NAME_CONTENTS.
PRO APPEND
PRO FIELDS TERMINATED BY ','
PRO (file_name,
PRO  contents lobfile(file_name) terminated by eof)
PRO EOF
PRO
PRO sqlldr &V_CONN \
PRO control="${v_outpref}_load.ctl" \
PRO errors=0 \
PRO discardmax=0 \
PRO direct=Y \
PRO data="${v_file}" \
PRO log="${v_outpref}_load.log"
PRO
PRO rm -f "${v_outpref}_load.log" "${v_outpref}_load.ctl" "${v_file}"
SPO OFF

--------------------------
-------- PREPARE ---------
--------------------------

! rm -f *_*.txt

-------------------------------------
------- LOAD CODES & CONTENTS -------
-------------------------------------

set serverout on lines 10000 trims on verify off feed off
SPOOL aaa.sql

DECLARE
  CURSOR V_VERS IS
    with versions as (select /*+ materialize */ * from mv_versions)
    select d.oraversion  ORAVERSION_D,
           d.oraseries   ORASERIES_D,
           d.orapatch    ORAPATCH_D,
           d.loaded_on   loaded_on,
           v2.oraversion ORAVERSION_FROM,
           v2.oraseries  ORASERIES_FROM,
           v2.orapatch   ORAPATCH_FROM,
           v1.oraversion ORAVERSION_TO,
           v1.oraseries  ORASERIES_TO,
           v1.orapatch   ORAPATCH_TO
    from   versions v1, versions v2, d_patch_ready d -- driver table
    where  v1.display_name_prev=v2.display_name
    and    d.diff_generated is null
    and    ((v1.oraversion=d.oraversion and v1.oraseries=d.oraseries and v1.orapatch=d.orapatch)
    or      (v2.oraversion=d.oraversion and v2.oraseries=d.oraseries and v2.orapatch=d.orapatch));
  CURSOR V_DIFF_CODES (P_ORAVERSION_TO IN varchar2, P_ORASERIES_TO IN varchar2, P_ORAPATCH_TO IN NUMBER) IS
    SELECT NVL(D1.MD5_HASH_UNWRAPPED,D1.MD5_HASH) OLD_VALUE,
                      NVL(D2.MD5_HASH_UNWRAPPED,D2.MD5_HASH) NEW_VALUE
      FROM R_HASH.F(P_ORAVERSION_TO,P_ORASERIES_TO,P_ORAPATCH_TO) D0, DM_CODES D1, DM_CODES D2
     WHERE D0.COMPARE_COLUMN_NAME='MD5_HASH'
       AND D1.MD5_HASH = D0.OLD_VALUE
       AND D2.MD5_HASH = D0.NEW_VALUE
     MINUS
    SELECT MD5_HASH_FROM, MD5_HASH_TO
      FROM DIFF_CODES;
  CURSOR V_DIFF_CONTENTS (P_ORAVERSION_TO IN varchar2, P_ORASERIES_TO IN varchar2, P_ORAPATCH_TO IN NUMBER) IS
    SELECT HEXTORAW(D0.OLD_VALUE) OLD_VALUE,
           HEXTORAW(D0.NEW_VALUE) NEW_VALUE
      FROM R_TXTCOLLECTION.F(P_ORAVERSION_TO, P_ORASERIES_TO, P_ORAPATCH_TO) D0
     WHERE D0.COMPARE_COLUMN_NAME='MD5_HASH'
     MINUS
    SELECT MD5_HASH_FROM, MD5_HASH_TO
      FROM DIFF_CONTENTS;
  V_FOUND BOOLEAN;
BEGIN
  FOR V IN V_VERS
  LOOP
    V_FOUND := FALSE;
    -- CODES
    ROLLBACK;
    R_HASH.L(V.ORAVERSION_FROM, V.ORASERIES_FROM, V.ORAPATCH_FROM, V.ORAVERSION_TO, V.ORASERIES_TO, V.ORAPATCH_TO);
    FOR I IN V_DIFF_CODES (V.ORAVERSION_TO, V.ORASERIES_TO, V.ORAPATCH_TO)
    LOOP
      DBMS_OUTPUT.PUT_LINE('! echo Processing ' || I.OLD_VALUE || '_' || I.NEW_VALUE);
      DBMS_OUTPUT.PUT_LINE('@get_code.sql ' || I.OLD_VALUE);
      DBMS_OUTPUT.PUT_LINE('@get_code.sql ' || I.NEW_VALUE);
      DBMS_OUTPUT.PUT_LINE('! sh gen_diff.sh codes ' || I.OLD_VALUE || ' ' || I.NEW_VALUE);
      DBMS_OUTPUT.PUT_LINE('! rm -f ' || I.OLD_VALUE || '.sql ' || I.NEW_VALUE || '.sql');
      V_FOUND := TRUE;
    END LOOP;
    -- CONTENTS
    ROLLBACK;
    R_TXTCOLLECTION.L(V.ORAVERSION_FROM, V.ORASERIES_FROM, V.ORAPATCH_FROM, V.ORAVERSION_TO, V.ORASERIES_TO, V.ORAPATCH_TO);
    FOR I IN V_DIFF_CONTENTS (V.ORAVERSION_TO, V.ORASERIES_TO, V.ORAPATCH_TO)
    LOOP
      DBMS_OUTPUT.PUT_LINE('! echo Processing ' || I.OLD_VALUE || '_' || I.NEW_VALUE);
      DBMS_OUTPUT.PUT_LINE('@get_contents.sql ' || I.OLD_VALUE);
      DBMS_OUTPUT.PUT_LINE('@get_contents.sql ' || I.NEW_VALUE);
      DBMS_OUTPUT.PUT_LINE('! sh gen_diff.sh contents ' || I.OLD_VALUE || ' ' || I.NEW_VALUE);
      DBMS_OUTPUT.PUT_LINE('! rm -f ' || I.OLD_VALUE || '.sql ' || I.NEW_VALUE || '.sql');
      V_FOUND := TRUE;
    END LOOP;
    ROLLBACK;
    -- When there is nothing to generate, update the DIFF_GENERATED column so next execution will not query it again.
    IF NOT V_FOUND
    THEN
      UPDATE D_PATCH_READY
      SET    DIFF_GENERATED=SYSTIMESTAMP
      WHERE  DIFF_GENERATED IS NULL
      AND    ORAVERSION=V.ORAVERSION_D
      AND    ORASERIES=V.ORASERIES_D
      AND    ORAPATCH=V.ORAPATCH_D
      AND    LOADED_ON=V.LOADED_ON;
      COMMIT;
    END IF;
  END LOOP;
END;
/
SPOOL OFF

@aaa.sql

--------------------------
------- LOAD CODES -------
--------------------------

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE &&V_TABLE_NAME_CODES. PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

CREATE TABLE &&V_TABLE_NAME_CODES.
(
  FILE_NAME   VARCHAR2(100) NOT NULL,
  CONTENTS    CLOB NOT NULL
)
COMPRESS NOLOGGING;

! sh load_codes.sh

SET TERMOUT ON ECHO ON

INSERT /*+ APPEND */
  INTO DIFF_CODES (MD5_HASH_FROM, MD5_HASH_TO, DIFF_CODE)
SELECT T1.HASH_FROM,
       T1.HASH_TO,
       T1.CONTENTS
FROM   ( SELECT SUBSTR(FILE_NAME,1,INSTR(FILE_NAME,'_',1,1)-1) HASH_FROM,
                SUBSTR(FILE_NAME,INSTR(FILE_NAME,'_',1,1)+1,INSTR(FILE_NAME,'.',1,1)-INSTR(FILE_NAME,'_',1,1)-1) HASH_TO,
                CONTENTS
           FROM &&V_TABLE_NAME_CODES. ) T1
-- We need this as some other sessions in parallel can end up inserting the same row.
WHERE  NOT EXISTS (SELECT 1
                     FROM DIFF_CODES D
                    WHERE D.MD5_HASH_FROM = T1.HASH_FROM AND D.MD5_HASH_TO = T1.HASH_TO);

COMMIT;

DROP TABLE &&V_TABLE_NAME_CODES. PURGE;

SET TERMOUT OFF ECHO OFF

! rm -f *_*.codes.txt
! rm -f load_codes.sh
! rm -f get_code.sql

-----------------------------
------- LOAD CONTENTS -------
-----------------------------

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE &&V_TABLE_NAME_CONTENTS. PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

CREATE TABLE &&V_TABLE_NAME_CONTENTS.
(
  FILE_NAME   VARCHAR2(100) NOT NULL,
  CONTENTS    CLOB NOT NULL
)
COMPRESS NOLOGGING;

! sh load_contents.sh

SET TERMOUT ON ECHO ON

INSERT /*+ APPEND */
  INTO DIFF_CONTENTS (MD5_HASH_FROM, MD5_HASH_TO, DIFF_CODE)
SELECT T1.HASH_FROM,
       T1.HASH_TO,
       T1.CONTENTS
FROM   ( SELECT SUBSTR(FILE_NAME,1,INSTR(FILE_NAME,'_',1,1)-1) HASH_FROM,
                SUBSTR(FILE_NAME,INSTR(FILE_NAME,'_',1,1)+1,INSTR(FILE_NAME,'.',1,1)-INSTR(FILE_NAME,'_',1,1)-1) HASH_TO,
                CONTENTS
           FROM &&V_TABLE_NAME_CONTENTS. ) T1
-- We need this as some other sessions in parallel can end up inserting the same row.
WHERE  NOT EXISTS (SELECT 1
                     FROM DIFF_CONTENTS D
                    WHERE D.MD5_HASH_FROM = T1.HASH_FROM AND D.MD5_HASH_TO = T1.HASH_TO);

COMMIT;

DROP TABLE &&V_TABLE_NAME_CONTENTS. PURGE;

SET TERMOUT OFF ECHO OFF

! rm -f *_*.contents.txt
! rm -f load_contents.sh
! rm -f get_contents.sql

----------------------
------- FINISH -------
----------------------

! rm -f gen_diff.sh
! rm -f aaa.sql