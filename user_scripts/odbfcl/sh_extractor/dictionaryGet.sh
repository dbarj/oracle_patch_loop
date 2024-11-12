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

[ -z "${v_dump_user_name}" ] && exitError "First parameter is the DB Schema and cannot be null."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

# If DB_EXP_CRED is exported, use it as the credentials.
[ -n "$DB_EXP_CRED" ] && v_sysdba_connect="$DB_EXP_CRED" || v_sysdba_connect='/ as sysdba'

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../extract # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
@hashGet.sql "${v_dump_user_name}" "${v_dump_dir_name}"
EOF

exit 0
###