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

# If DB_EXP_USER_PASS is exported, use it.
[ -z "$DB_EXP_USER_PASS" ] && DB_EXP_USER_PASS='HhAaSsHh..135'

# If DB_EXP_USER_TBS is exported, use it.
[ -z "$DB_EXP_USER_TBS" ] && DB_EXP_USER_TBS='USERS'

# If DB_EXP_USER_TEMP is exported, use it.
[ -z "$DB_EXP_USER_TEMP" ] && DB_EXP_USER_TEMP='TEMP'

# If DB_EXP_CONN is exported, use it as the credentials.
[ -z "$DB_EXP_CONN" ] && DB_EXP_CONN='/ as sysdba'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

echo "Creating export user. Please wait.." 

cd "${v_thisdir}"/../ # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus "${DB_EXP_CONN}" <<EOF
set verify off
@tables_recreate.sql "${v_dump_user_name}" "${DB_EXP_USER_PASS}" "${DB_EXP_USER_TBS}" "${DB_EXP_USER_TEMP}" "${v_drop_dump_user}"
EOF

exit 0
###