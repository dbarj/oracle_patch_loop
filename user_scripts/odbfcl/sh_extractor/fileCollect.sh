#!/bin/bash
# Script to get all non-binary files in ORACLE_HOME
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

v_output="$1"

[ -z "$v_output" ] && exitError "First parameter is the target file and cannot be null."
[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

v_output_fdr="$(cd "$(dirname "${v_output}")"; pwd)"
v_output_file="$(basename "${v_output}")"

v_output_full="${v_output_fdr}/${v_output_file}"

echo "Generating ORACLE_HOME non-binary files list. Please wait.." 

cd "$ORACLE_HOME"
find -type f -not -path "./.patch_storage/*" -not -name "tfa_setup" -print0 | xargs -0 grep -Il '.' | tar -czf "${v_output_full}" -T -

exit 0