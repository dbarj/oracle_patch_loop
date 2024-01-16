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

v_dump_user="$1"

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_DUMP_PASS is exported, use it as the password.
[ -n "$DB_EXP_DUMP_PASS" ] && v_dump_pass="$DB_EXP_DUMP_PASS" || v_dump_pass='HhAaSsHh..135'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Generating export user. Please wait.." 

cd "${v_thisdir}"/../
$ORACLE_HOME/bin/sqlplus "${v_sysdba_connect}" <<EOF
set verify off
@tables_recreate.sql "${v_dump_user}" "${v_dump_pass}"
EOF

exit 0
###