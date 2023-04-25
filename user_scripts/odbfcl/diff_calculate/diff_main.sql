WHENEVER SQLERROR CONTINUE

CREATE TABLE "DIFF_CODES"
(
    "MD5_HASH_FROM" RAW(16) NOT NULL,
    "MD5_HASH_TO"   RAW(16) NOT NULL,
    "DIFF_CODE"     CLOB    NOT NULL,
    CONSTRAINT DIFF_CODES_PK PRIMARY KEY ("MD5_HASH_FROM", "MD5_HASH_TO"),
    CONSTRAINT DIFF_CODES_F1 FOREIGN KEY ("MD5_HASH_FROM") REFERENCES DM_CODES ("MD5_HASH") ON DELETE CASCADE,
    CONSTRAINT DIFF_CODES_F2 FOREIGN KEY ("MD5_HASH_TO")   REFERENCES DM_CODES ("MD5_HASH") ON DELETE CASCADE
)
COMPRESS NOLOGGING;

CREATE INDEX "DIFF_CODES_F1" ON "DIFF_CODES" ("MD5_HASH_FROM");
CREATE INDEX "DIFF_CODES_F2" ON "DIFF_CODES" ("MD5_HASH_TO");

CREATE TABLE "DIFF_CONTENTS"
(
    "MD5_HASH_FROM" RAW(16) NOT NULL,
    "MD5_HASH_TO"   RAW(16) NOT NULL,
    "DIFF_CODE"     CLOB    NOT NULL,
    CONSTRAINT DIFF_CONTENTS_PK PRIMARY KEY ("MD5_HASH_FROM", "MD5_HASH_TO"),
    CONSTRAINT DIFF_CONTENTS_F1 FOREIGN KEY ("MD5_HASH_FROM") REFERENCES DM_CONTENTS ("MD5_HASH") ON DELETE CASCADE,
    CONSTRAINT DIFF_CONTENTS_F2 FOREIGN KEY ("MD5_HASH_TO")   REFERENCES DM_CONTENTS ("MD5_HASH") ON DELETE CASCADE
)
COMPRESS NOLOGGING;

CREATE INDEX "DIFF_CONTENTS_F1" ON "DIFF_CONTENTS" ("MD5_HASH_FROM");
CREATE INDEX "DIFF_CONTENTS_F2" ON "DIFF_CONTENTS" ("MD5_HASH_TO");

WHENEVER SQLERROR EXIT SQL.SQLCODE

DEF P_CRED   = '&1' 
DEF P_FOLDER = '&2' 
DEF P_VERS   = '&3' 
DEF P_SER    = '&4'
DEF P_PATCH  = '&5'

set pages 0
set long 1000000
set lines 10000
set trims on
set feed off
set echo off
set verify off
col code for a10000
set termout off
spo run_code.sql
with versions as (select /*+ materialize */ * from ld_versions)
select '@&P_FOLDER./diff_calculate.sql ' ||
       '''&P_CRED.'' ' || -- P1
       '''' || v2.oraversion || ''' ' || -- P2
       '''' || v2.oraseries || ''' ' || -- P3
       '''' || v2.orapatch || ''' ' || -- P4
       '''' || v1.oraversion || ''' ' || -- P5
       '''' || v1.oraseries || ''' ' || -- P6
       '''' || v1.orapatch || ''' ' || -- P7
       '''' || REPLACE('&P_VERS.','.','') || '''' -- P8
from   versions v1, versions v2
where  v1.display_name_prev=v2.display_name
and  ((v1.oraversion='&P_VERS.' and v1.oraseries='&P_SER.' and v1.orapatch=&P_PATCH.)
or    (v2.oraversion='&P_VERS.' and v2.oraseries='&P_SER.' and v2.orapatch=&P_PATCH.));
spool off

@run_code.sql

! rm -f run_code.sql

exit