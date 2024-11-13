#!/bin/bash
# Script to load all non-binary files on database

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
v_data_file_param="$2"
v_out_prefix="${v_data_file_param%.*}"

[ -z "${v_dump_user_name}" ] && exitError "1st parameter is the DB Schema and cannot be null."
[ -z "${v_data_file_param}" ] && exitError "2nd parameter is the source file and cannot be null."

[ ! -f "${v_data_file_param}" -o ! -r "${v_data_file_param}" ] && exitError "File '${v_data_file_param}' does not exist."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_CRED is exported, use it as the credentials.
[ -n "$DB_EXP_CRED" ] && v_sysdba_connect="$DB_EXP_CRED" || v_sysdba_connect='/ as sysdba'

echo "Loading ORACLE_HOME non-binary files. Please wait.." 

v_control_file="${v_out_prefix}_load.ctl"
v_log_file="${v_out_prefix}_load.log"
v_unzip_folder="${v_out_prefix}_unzip"
v_list_file="unzip_files.txt"

rm -rf "${v_unzip_folder}"
mkdir "${v_unzip_folder}"
tar -tvf "${v_data_file_param}" | grep -o '\./.*' > "${v_unzip_folder}/${v_list_file}"
tar -xf "${v_data_file_param}" -C "${v_unzip_folder}"

cd "${v_unzip_folder}"

$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
whenever sqlerror exit failure rollback
create table ${v_dump_user_name}.t_txtcollection_load
( path varchar2(500) not null, contents clob not null, md5_hash raw(16) )
compress nologging;
EOF

cat << EOF > "${v_control_file}"
LOAD
INTO TABLE ${v_dump_user_name}.T_TXTCOLLECTION_LOAD
APPEND
FIELDS TERMINATED BY ','
(path char(4000), contents lobfile(path) terminated by eof)
EOF

$ORACLE_HOME/bin/sqlldr \
userid=\'"${v_sysdba_connect}"\' \
control="${v_control_file}" \
errors=0 \
discardmax=0 \
direct=Y \
data="${v_list_file}" \
log="${v_log_file}"

cd ..
rm -rf "${v_unzip_folder}"

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