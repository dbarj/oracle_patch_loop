WHENEVER SQLERROR EXIT SQL.SQLCODE

DEF V_CONN      = '&1'
DEF V_VERS_FROM = '&2'
DEF V_VERS_TO   = '&3'

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
PRO set -e
PRO v_file_1="$1"
PRO v_file_2="$2"
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
PRO sdiff -w ${v_size} -bB -t -l "${v_file_1}.sql" "${v_file_2}.sql" | cat -n | grep -v -e '($' > "${v_file_1}_${v_file_2}.txt"
SPO OFF

SPO load_codes.sh
PRO set -e
PRO
PRO v_outpref="./list"
PRO v_file="${v_outpref}.csv"
PRO
PRO if ! ls *_*.txt >/dev/null 2>/dev/null
PRO then
PRO   echo "No file to process."
PRO   exit 0
PRO fi
PRO
PRO ls -1 *_*.txt > "${v_file}"
PRO
PRO cat << EOF > "${v_outpref}_load.ctl"
PRO LOAD
PRO INTO TABLE DIFF_CODES_LOAD
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
PRO set -e
PRO
PRO v_outpref="./list"
PRO v_file="${v_outpref}.csv"
PRO
PRO if ! ls *_*.txt >/dev/null 2>/dev/null
PRO then
PRO   echo "No file to process."
PRO   exit 0
PRO fi
PRO
PRO ls -1 *_*.txt > "${v_file}"
PRO
PRO cat << EOF > "${v_outpref}_load.ctl"
PRO LOAD
PRO INTO TABLE DIFF_CONTENTS_LOAD
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
------- LOAD CODES -------
--------------------------

! rm -f *_*.txt

-- For Labels
BEGIN
  ADMIN.INITAPEXFROMOUTSIDE(100,2,'XYZ') ;
  APEX_UTIL.SET_SESSION_STATE('ALLOW_LABELS','Y');
END;
/

ROLLBACK;
EXEC L_HASH('&V_VERS_FROM','&V_VERS_TO');

set serverout on lines 10000 trims on verify off feed off
SPOOL aaa.sql
BEGIN
  FOR I IN (SELECT NVL(D1.MD5_HASH_UNWRAPPED,D1.MD5_HASH) OLD_VALUE,
                   NVL(D2.MD5_HASH_UNWRAPPED,D2.MD5_HASH) NEW_VALUE
              FROM P_HASH.F('&V_VERS_TO') D0, DM_CODES D1, DM_CODES D2
             WHERE D0.COMPARE_COLUMN_NAME='MD5_HASH'
               AND D1.MD5_HASH = D0.OLD_VALUE
               AND D2.MD5_HASH = D0.NEW_VALUE
             MINUS
            SELECT MD5_HASH_FROM, MD5_HASH_TO
              FROM DIFF_CODES)
  LOOP
    DBMS_OUTPUT.PUT_LINE('@get_code.sql ' || I.OLD_VALUE);
    DBMS_OUTPUT.PUT_LINE('@get_code.sql ' || I.NEW_VALUE);
    DBMS_OUTPUT.PUT_LINE('! sh gen_diff.sh ' || I.OLD_VALUE || ' ' || I.NEW_VALUE);
    DBMS_OUTPUT.PUT_LINE('! rm -f ' || I.OLD_VALUE || '.sql ' || I.NEW_VALUE || '.sql');
    DBMS_OUTPUT.PUT_LINE('! echo Processing ' || I.OLD_VALUE || '_' || I.NEW_VALUE);
  END LOOP;
END;
/
SPOOL OFF

@aaa.sql

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE DIFF_CODES_LOAD PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

CREATE TABLE DIFF_CODES_LOAD
(
  FILE_NAME   VARCHAR2(100) NOT NULL,
  CONTENTS    CLOB NOT NULL
)
COMPRESS NOLOGGING;

! sh load_codes.sh

insert /*+ append */
  into DIFF_CODES (MD5_HASH_FROM, MD5_HASH_TO, DIFF_CODE)
select substr(file_name,1,instr(file_name,'_',1,1)-1),
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'.',1,1)-instr(file_name,'_',1,1)-1),
       CONTENTS
from DIFF_CODES_LOAD;

commit;

DROP TABLE DIFF_CODES_LOAD PURGE;

! rm -f *_*.txt
! rm -f load_codes.sh
! rm -f get_code.sql

-----------------------------
------- LOAD CONTENTS -------
-----------------------------

ROLLBACK;
EXEC L_TXTCOLLECTION('&V_VERS_FROM','&V_VERS_TO');

set serverout on lines 10000 trims on verify off feed off
SPOOL aaa.sql
BEGIN
  FOR I IN (SELECT HEXTORAW(D0.OLD_VALUE) OLD_VALUE,
                   HEXTORAW(D0.NEW_VALUE) NEW_VALUE
              FROM P_TXTCOLLECTION.F('&V_VERS_TO') D0
             WHERE D0.COMPARE_COLUMN_NAME='MD5_HASH'
             MINUS
            SELECT MD5_HASH_FROM, MD5_HASH_TO
              FROM DIFF_CONTENTS)
  LOOP
    DBMS_OUTPUT.PUT_LINE('@get_contents.sql ' || I.OLD_VALUE);
    DBMS_OUTPUT.PUT_LINE('@get_contents.sql ' || I.NEW_VALUE);
    DBMS_OUTPUT.PUT_LINE('! sh gen_diff.sh ' || I.OLD_VALUE || ' ' || I.NEW_VALUE);
    DBMS_OUTPUT.PUT_LINE('! rm -f ' || I.OLD_VALUE || '.sql ' || I.NEW_VALUE || '.sql');
    DBMS_OUTPUT.PUT_LINE('! echo Processing ' || I.OLD_VALUE || '_' || I.NEW_VALUE);
  END LOOP;
END;
/
SPOOL OFF

@aaa.sql

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE DIFF_CONTENTS_LOAD PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

CREATE TABLE DIFF_CONTENTS_LOAD
(
  FILE_NAME   VARCHAR2(100) NOT NULL,
  CONTENTS    CLOB NOT NULL
)
COMPRESS NOLOGGING;

! sh load_contents.sh

insert /*+ append */
  into DIFF_CONTENTS (MD5_HASH_FROM, MD5_HASH_TO, DIFF_CODE)
select substr(file_name,1,instr(file_name,'_',1,1)-1),
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'.',1,1)-instr(file_name,'_',1,1)-1),
       CONTENTS
from DIFF_CONTENTS_LOAD;

commit;

DROP TABLE DIFF_CONTENTS_LOAD PURGE;

! rm -f *_*.txt
! rm -f load_contents.sh
! rm -f get_contents.sql

! rm -f gen_diff.sh
! rm -f aaa.sql