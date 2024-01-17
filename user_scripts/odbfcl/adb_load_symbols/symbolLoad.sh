#!/bin/bash
# Script to load all symbols on database
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
v_file="$2"
v_outpref="${v_file}"

[ -z "$v_file" ] && exitError "First parameter is the source file and cannot be null."
[ ! -f "${v_file}" -o ! -r "${v_file}" ] && exitError "File '${v_file}' does not exist."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Loading symbols list. Please wait.." 

cat << EOF > "${v_outpref}_load.ctl"
LOAD
INTO TABLE ${v_dump_user_name}.T_SYMBOLS
APPEND
FIELDS TERMINATED BY '|'
(file_name, symbol_type, symbol_name char(4000))
EOF

$ORACLE_HOME/bin/sqlldr \
userid=\'"${v_sysdba_connect}"\' \
control="${v_outpref}_load.ctl" \
errors=0 \
discardmax=0 \
direct=Y \
data="${v_file}" \
log="${v_outpref}_load.log"

rm -f "${v_outpref}_load.log" "${v_outpref}_load.ctl"

exit 0