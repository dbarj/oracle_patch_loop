#!/bin/bash
# Script to list all symbols in ORACLE_HOME
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>

# set -eo pipefail
set -e # grep can return 0 lines

function echoError ()
{
  (>&2 echo "$1")
}

function exitError ()
{
  echoError "$1"
  exit 1
}

v_output="$1"

[ -z "$v_output" ] && exitError "First parameter is the target file and cannot be null."
[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

echo > "${v_output}"

echo "Generating symbols list. Please wait.." 

# Extract Symbols from Oracle archives (.a)
for ARCHIVE in $(ls $ORACLE_HOME/lib/*.a $ORACLE_HOME/rdbms/lib/*.a)
do
  nm -A $ARCHIVE | grep ' [Tt] ' | tr ':' ' ' | cut -d" " -f1,2,4,5 | sort -u | awk '{ if ( $4 != "" ) { file=$1; sub(".*/","", file); printf "%s/%s|%s|%s\n", file, $2, $3, $4 } }' >> "${v_output}"
done

# Extract Symbols from Oracle objects (.o)
for OBJECT in $(ls $ORACLE_HOME/lib/*.o $ORACLE_HOME/rdbms/lib/*.o)
do
  nm -A $OBJECT | grep ' [Tt] ' | tr ':' ' ' | cut -d" " -f1,3,4 | sort -u | awk '{ if ( $3 != "" ) { file=$1; sub(".*/","", file); printf "%s|%s|%s\n", file, $2, $3 } }' >> "${v_output}"
done

# Extract Symbols from Oracle executable
nm -A -C $ORACLE_HOME/bin/oracle | grep ' [TtDdRrVv] ' | tr ':' ' ' | cut -d" " -f1,3,4 | sort -u | awk '{ if ( $3 != "" ) { file=$1; sub(".*/","", file); printf "%s|%s|%s\n", file, $2, $3 } }' >> "${v_output}"

# Remove empty lines or sqlldr will fail due to constant.
sed -i '/^$/d' "${v_output}"

exit 0