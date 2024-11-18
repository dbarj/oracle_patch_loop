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
v_out_prefix="${v_out_prefix%.*}" # Remove second extension

[ -z "${v_dump_user_name}" ] && exitError "1st parameter is the DB Schema and cannot be null."
[ -z "${v_data_file_param}" ] && exitError "2nd parameter is the source file and cannot be null."

[ ! -f "${v_data_file_param}" -o ! -r "${v_data_file_param}" ] && exitError "File '${v_data_file_param}' does not exist."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_CONN is exported, use it as the credentials.
[ -z "$DB_EXP_CONN" ] && DB_EXP_CONN='/ as sysdba'

echo "Loading ORACLE_HOME non-binary files. Please wait.." 

v_control_file="${v_out_prefix}_load.ctl"
v_log_file="${v_out_prefix}_load.log"
v_untar_folder="${v_out_prefix}_untar"
v_list_file="tar_list_files.txt"

rm -rf "${v_untar_folder}"
mkdir "${v_untar_folder}"
tar -tvf "${v_data_file_param}" | grep -o '\./.*' > "${v_untar_folder}/${v_list_file}"
tar -xf "${v_data_file_param}" -C "${v_untar_folder}"

cd "${v_untar_folder}"

$ORACLE_HOME/bin/sqlplus -L -S "${DB_EXP_CONN}" <<EOF
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

set +e
$ORACLE_HOME/bin/sqlldr \
userid=\'"${DB_EXP_CONN}"\' \
control="${v_control_file}" \
errors=0 \
discardmax=0 \
direct=Y \
data="${v_list_file}" \
log="${v_log_file}"
v_ret=$?
set -eo pipefail

if [ $v_ret -ne 0 ]
then
  exitError "sqlldr failed to load '${v_data_file_param}'. Check also the 'bad' file for more information."
fi

cd ..
rm -rf "${v_untar_folder}"

$ORACLE_HOME/bin/sqlplus -L -S "${DB_EXP_CONN}" <<EOF
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