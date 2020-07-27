#!/bin/bash
set -e

curdir=`pwd`

export ORACLE_SID=orcl
export ORAENV_ASK=NO
export PATH=$PATH:/usr/local/bin
. oraenv

username="c##hash"
filesdir="$1"
vers="$2"

[ -z "$filesdir" ] && echo "Param 1 is null" && exit 1
[ -z "$vers" ] && echo "Param 2 is null" && exit 1

cat << EOF > ${curdir}/load.sql
whenever sqlerror exit sql.sqlcode

BEGIN EXECUTE IMMEDIATE 'DROP TABLE T_FILES_LOAD PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE T_FILES_LOAD (
  FILE_NAME  VARCHAR2(50)  NOT NULL,
  HASH       RAW(32)       NOT NULL,
  PATH       VARCHAR2(500) NOT NULL)
COMPRESS NOLOGGING;

exit 0;
EOF

sqlplus ${username}/hash @$curdir/load.sql

for i in `cd $filesdir; ls -1 sha256sum*_${vers}_*.chk`
do
cat << EOF > ${curdir}/load.ctl
LOAD
INTO TABLE T_FILES_LOAD
APPEND
FIELDS TERMINATED BY '  '
(file_name constant "$i",hash,path)
EOF
echo $i
sqlldr ${username}/hash control=${curdir}/load.ctl errors=0 discardmax=0 direct=true data=${filesdir}/${i} log=${filesdir}/${i}.log
done

rm -f ${curdir}/load.ctl

cat << EOF > ${curdir}/load.sql
whenever sqlerror exit sql.sqlcode

BEGIN EXECUTE IMMEDIATE 'DROP TABLE T_FILES PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE T_FILES (
  PATH        VARCHAR2(500),
  SHA256_ENC  RAW(32),
  SERIES      VARCHAR2(10),
  ORAVERSION  VARCHAR2(20),
  PSU         NUMBER)
COMPRESS NOLOGGING;

insert /*+ append */ into T_FILES (PATH, SHA256_ENC, ORAVERSION, SERIES, PSU)
select path,
       hash,
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'_',1,2)-instr(file_name,'_',1,1)-1)           oraversion,
       substr(file_name,instr(file_name,'_',1,2)+1,instr(file_name,'_',1,3)-instr(file_name,'_',1,2)-1)           series,
       to_number(substr(file_name,instr(file_name,'_',1,3)+1,instr(file_name,'.',-1)-instr(file_name,'_',1,3)-1)) psu
from T_FILES_LOAD;
commit;

set tab off
SELECT SERIES,ORAVERSION,PSU,COUNT(*) FROM T_FILES GROUP BY SERIES,ORAVERSION,PSU ORDER BY 1,2;

exit 0;
EOF

sqlplus ${username}/hash @$curdir/load.sql

rm -f ${curdir}/load.sql

exit 0
###