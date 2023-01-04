set termout on
set feed off
set trims on
set trim on
set pages 0
set lines 10000
set long 100000
set longc 100000
set head off
set echo off
set verify off
SET SERVEROUTPUT ON FORMAT WRAPPED

def output_path = '/media/sf_Patch'

CREATE OR REPLACE FUNCTION QA (IN_VALUE IN VARCHAR2) RETURN VARCHAR2 AS
  V_ENC VARCHAR2(1) := '"';
  V_SEP VARCHAR2(1) := ',';
  OUT_VALUE   VARCHAR2(4000);
BEGIN
  IF IN_VALUE IS NOT NULL THEN
    OUT_VALUE := REPLACE(REPLACE(IN_VALUE,CHR(13),' '),CHR(10),' ');
    IF OUT_VALUE LIKE '%' || V_ENC || '%' OR OUT_VALUE LIKE '%' || V_SEP || '%' THEN
      RETURN V_ENC || REPLACE(OUT_VALUE,V_ENC,V_ENC || V_ENC) || V_ENC;
    ELSE
      RETURN OUT_VALUE;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
END;
/

VAR PRINT_COLS CLOB

EXEC :PRINT_COLS := 'qa(' || REPLACE(:v_print_cols,',',') || '','' || qa(') || ')';

--v_print_table    = 't_col_privs'
--v_file_pref     = 'privs_col'
--v_srczip_pref   = 'privs'

set def off
spool /tmp/apoio.sql
SELECT 'SELECT DISTINCT ' || :PRINT_COLS || q'[ || ',' || qa(series) || ',' || qa(oraversion) || ',' || qa(psu_from) || ',' || qa(psu_to) || DECODE(FLAG,'R',',' || QA('-')) from &&v_print_table._F where oraversion='&&oraversion.' order by 1;]'
from dual;
spool off
set def on

COL EXEC1 NEW_V EXEC1 NOPRI
COL EXEC2 NEW_V EXEC2 NOPRI
COL EXEC3 NEW_V EXEC3 NOPRI
COL EXEC4 NEW_V EXEC4 NOPRI

-----------

def oraversion = "11.2.0.4"
def exec1 = ''
def exec2 = ''
def exec3 = ''
def exec4 = ''

SELECT 'spool &&output_path./&&v_file_pref..&&oraversion..csv' EXEC1,
       '@@/tmp/apoio.sql' EXEC2,
       'spool off' EXEC3,
       'HOS zip -m -j -9 &&output_path./&&v_srczip_pref..csv.zip &&output_path./&&v_file_pref..&&oraversion..csv' EXEC4
FROM DUAL where exists (select 1 from &&v_print_table._F where oraversion='&&oraversion.');

spool /tmp/exec.sql
PRO &&EXEC1.
PRO &&EXEC2.
PRO &&EXEC3.
PRO &&EXEC4.
spool off
@@/tmp/exec.sql

-----------

def oraversion = "12.1.0.1"
def exec1 = ''
def exec2 = ''
def exec3 = ''
def exec4 = ''

SELECT 'spool &&output_path./&&v_file_pref..&&oraversion..csv' EXEC1,
       '@@/tmp/apoio.sql' EXEC2,
       'spool off' EXEC3,
       'HOS zip -m -j -9 &&output_path./&&v_srczip_pref..csv.zip &&output_path./&&v_file_pref..&&oraversion..csv' EXEC4
FROM DUAL where exists (select 1 from &&v_print_table._F where oraversion='&&oraversion.');

spool /tmp/exec.sql
PRO &&EXEC1.
PRO &&EXEC2.
PRO &&EXEC3.
PRO &&EXEC4.
spool off
@@/tmp/exec.sql

-----------

def oraversion = "12.1.0.2"
def exec1 = ''
def exec2 = ''
def exec3 = ''
def exec4 = ''

SELECT 'spool &&output_path./&&v_file_pref..&&oraversion..csv' EXEC1,
       '@@/tmp/apoio.sql' EXEC2,
       'spool off' EXEC3,
       'HOS zip -m -j -9 &&output_path./&&v_srczip_pref..csv.zip &&output_path./&&v_file_pref..&&oraversion..csv' EXEC4
FROM DUAL where exists (select 1 from &&v_print_table._F where oraversion='&&oraversion.');

spool /tmp/exec.sql
PRO &&EXEC1.
PRO &&EXEC2.
PRO &&EXEC3.
PRO &&EXEC4.
spool off
@@/tmp/exec.sql

-----------

def oraversion = "12.2.0.1"
def exec1 = ''
def exec2 = ''
def exec3 = ''
def exec4 = ''

SELECT 'spool &&output_path./&&v_file_pref..&&oraversion..csv' EXEC1,
       '@@/tmp/apoio.sql' EXEC2,
       'spool off' EXEC3,
       'HOS zip -m -j -9 &&output_path./&&v_srczip_pref..csv.zip &&output_path./&&v_file_pref..&&oraversion..csv' EXEC4
FROM DUAL where exists (select 1 from &&v_print_table._F where oraversion='&&oraversion.');

spool /tmp/exec.sql
PRO &&EXEC1.
PRO &&EXEC2.
PRO &&EXEC3.
PRO &&EXEC4.
spool off
@@/tmp/exec.sql

-----------

def oraversion = "18.0.0.0"
def exec1 = ''
def exec2 = ''
def exec3 = ''
def exec4 = ''

SELECT 'spool &&output_path./&&v_file_pref..&&oraversion..csv' EXEC1,
       '@@/tmp/apoio.sql' EXEC2,
       'spool off' EXEC3,
       'HOS zip -m -j -9 &&output_path./&&v_srczip_pref..csv.zip &&output_path./&&v_file_pref..&&oraversion..csv' EXEC4
FROM DUAL where exists (select 1 from &&v_print_table._F where oraversion='&&oraversion.');

spool /tmp/exec.sql
PRO &&EXEC1.
PRO &&EXEC2.
PRO &&EXEC3.
PRO &&EXEC4.
spool off
@@/tmp/exec.sql

-----------

def oraversion = "19.0.0.0"
def exec1 = ''
def exec2 = ''
def exec3 = ''
def exec4 = ''

SELECT 'spool &&output_path./&&v_file_pref..&&oraversion..csv' EXEC1,
       '@@/tmp/apoio.sql' EXEC2,
       'spool off' EXEC3,
       'HOS zip -m -j -9 &&output_path./&&v_srczip_pref..csv.zip &&output_path./&&v_file_pref..&&oraversion..csv' EXEC4
FROM DUAL where exists (select 1 from &&v_print_table._F where oraversion='&&oraversion.');

spool /tmp/exec.sql
PRO &&EXEC1.
PRO &&EXEC2.
PRO &&EXEC3.
PRO &&EXEC4.
spool off
@@/tmp/exec.sql

-----------

undef oraversion

undef v_print_table v_file_pref v_srczip_pref

DROP FUNCTION QA;

--HOS rm /tmp/exec.sql /tmp/apoio.sql

set termout on
set feed on
set echo on
set verify on
