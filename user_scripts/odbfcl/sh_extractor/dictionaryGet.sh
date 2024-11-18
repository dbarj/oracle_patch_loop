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

[ -z "${v_dump_user_name}" ] && exitError "1st parameter is the DB Schema and cannot be null."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_CONN is exported, use it.
[ -z "$DB_EXP_CONN" ] && DB_EXP_CONN='/ as sysdba'

# If DB_EXP_DIRECTORY is exported, use it.
[ -z "$DB_EXP_DIRECTORY" ] && DB_EXP_DIRECTORY='expdir_oradiff'

# If DB_EXP_INTERNAL_ONLY is exported, use it.
[ -z "$DB_EXP_INTERNAL_ONLY" ] && DB_EXP_INTERNAL_ONLY='true'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../extract # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus -L -S "${DB_EXP_CONN}" <<EOF
@hashGet.sql "${v_dump_user_name}" "${DB_EXP_DIRECTORY}" "${DB_EXP_INTERNAL_ONLY}"
EOF

exit 0
###