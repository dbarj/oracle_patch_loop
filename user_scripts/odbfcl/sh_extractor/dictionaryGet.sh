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

v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../extract
$ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" <<EOF
@hashGet.sql "${v_dump_user}" "${v_dump_dir_name}"
EOF

exit 0
###