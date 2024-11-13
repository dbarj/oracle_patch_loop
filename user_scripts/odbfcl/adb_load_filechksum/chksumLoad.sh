#!/bin/bash
# Script to load all sha256sum on database

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

echo "Loading sha256sum list. Please wait.." 

v_control_file="${v_out_prefix}_load.ctl"
v_log_file="${v_out_prefix}_load.log"

cat << EOF > "${v_control_file}"
LOAD
INTO TABLE ${v_dump_user_name}.T_FILES
APPEND
FIELDS TERMINATED BY '  '
(sha256_hash, path char(4000), file_type)
EOF

set +e
$ORACLE_HOME/bin/sqlldr \
userid=\'"${v_sysdba_connect}"\' \
control="${v_control_file}" \
errors=0 \
discardmax=0 \
direct=Y \
data="${v_data_file_param}" \
log="${v_log_file}"
v_ret=$?
set -eo pipefail

if [ $v_ret -ne 0 ]
then
  exitError "sqlldr failed to load '${v_data_file_param}'. Check also the 'bad' file for more information."
fi

rm -f "${v_log_file}" "${v_control_file}"

exit 0