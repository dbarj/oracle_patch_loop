#!/bin/bash
# Script to collect dictionary tables

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
v_drop_dump_user="$2"

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

[ -z "${v_dump_user_name}" ] && exitError "1st parameter is the DB Schema and cannot be null."
[ -z "${v_drop_dump_user}" ] && exitError "2nd parameter is if DB Schema can be dropped and cannot be null."

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_PASS" ] && v_dump_user_pass="$DB_EXP_USER_PASS" || v_dump_user_pass='HhAaSsHh..135'

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_TBS" ] && v_dump_user_tbs="$DB_EXP_USER_TBS" || v_dump_user_tbs='USERS'

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_TEMP" ] && v_dump_user_temp="$DB_EXP_USER_TEMP" || v_dump_user_temp='TEMP'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

# If DB_EXP_CRED is exported, use it as the credentials.
[ -n "$DB_EXP_CRED" ] && v_sysdba_connect="$DB_EXP_CRED" || v_sysdba_connect='/ as sysdba'

echo "Creating export user. Please wait.." 

cd "${v_thisdir}"/../ # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus "${v_sysdba_connect}" <<EOF
set verify off
@tables_recreate.sql "${v_dump_user_name}" "${v_dump_user_pass}" "${v_dump_user_tbs}" "${v_dump_user_temp}" "${v_drop_dump_user}"
EOF

exit 0
###