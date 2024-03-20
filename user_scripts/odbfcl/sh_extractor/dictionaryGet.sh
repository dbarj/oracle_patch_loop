#!/bin/bash
# Script to collect dictionary tables
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

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../extract # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
@hashGet.sql "${v_dump_user_name}" "${v_dump_dir_name}"
EOF

exit 0
###