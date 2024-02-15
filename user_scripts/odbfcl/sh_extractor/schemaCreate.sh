#!/bin/bash
# Script to collect dictionary tables
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>

set -eo pipefail

function echoError ()
{
  (>&2 echo "$1")
}

function exitError ()
{
  echoError "$1"
  exit 1
}

v_dump_user_name="$1"

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_PASS" ] && v_dump_user_pass="$DB_EXP_USER_PASS" || v_dump_user_pass='HhAaSsHh..135'

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_TBS" ] && v_dump_user_tbs="$DB_EXP_USER_TBS" || v_dump_user_tbs='USERS'

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_TEMP" ] && v_dump_user_temp="$DB_EXP_USER_TEMP" || v_dump_user_temp='TEMP'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Creating export user. Please wait.." 

cd "${v_thisdir}"/../ # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus "${v_sysdba_connect}" <<EOF
set verify off
@tables_recreate.sql "${v_dump_user_name}" "${v_dump_user_pass}" "${v_dump_user_tbs}" "${v_dump_user_temp}"
EOF

exit 0
###