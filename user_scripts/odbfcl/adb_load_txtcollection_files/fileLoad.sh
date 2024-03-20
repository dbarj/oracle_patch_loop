#!/bin/bash
# Script to load all non-binary files on database
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>

set -eo pipefail

echoError ()
{
  (>&2 echo "$1")
}

exitError ()
{
  echoError "$1"
  exit 1
}

v_dump_user_name="$1"
v_file="$2"
v_outpref="${v_file}"

[ -z "${v_file}" ] && exitError "First parameter is the source file and cannot be null."
[ ! -f "${v_file}" -o ! -r "${v_file}" ] && exitError "File '${v_file}' does not exist."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Loading ORACLE_HOME non-binary files. Please wait.." 

rm -rf "${v_outpref}_unzip"
mkdir "${v_outpref}_unzip"
tar -tvf "${v_file}" | grep -o '\./.*' > "${v_outpref}_unzip/${v_file}_files.txt"
tar -xf "${v_file}" -C "${v_outpref}_unzip"

cd "${v_outpref}_unzip"

$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
whenever sqlerror exit failure rollback
create table ${v_dump_user_name}.t_txtcollection_load
( path varchar2(500) not null, contents clob not null, md5_hash raw(16) )
compress nologging;
EOF

cat << EOF > "${v_outpref}_load.ctl"
LOAD
INTO TABLE ${v_dump_user_name}.T_TXTCOLLECTION_LOAD
APPEND
FIELDS TERMINATED BY ','
(path char(4000), contents lobfile(path) terminated by eof)
EOF

$ORACLE_HOME/bin/sqlldr \
userid=\'"${v_sysdba_connect}"\' \
control="${v_outpref}_load.ctl" \
errors=0 \
discardmax=0 \
direct=Y \
data="${v_file}_files.txt" \
log="${v_outpref}_load.log"

cd ..
rm -rf "${v_outpref}_unzip"

$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
whenever sqlerror exit failure rollback
update ${v_dump_user_name}.t_txtcollection_load
set md5_hash=sys.dbms_crypto.hash(contents,2);

insert /*+ append */ into ${v_dump_user_name}.dm_contents (md5_hash, contents)
select md5_hash, contents
from (
  select md5_hash, contents, rank() over (partition by md5_hash order by rowid asc) col_ind
  from   ${v_dump_user_name}.t_txtcollection_load
)
where col_ind=1;

insert /*+ append */ into ${v_dump_user_name}.t_txtcollection (path, md5_hash)
select path, md5_hash
from   ${v_dump_user_name}.t_txtcollection_load;

commit;

drop table ${v_dump_user_name}.t_txtcollection_load purge;
EOF

exit 0