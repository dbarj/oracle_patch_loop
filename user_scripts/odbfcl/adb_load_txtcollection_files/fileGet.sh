#!/bin/bash
# Script to get all non-binary files in ORACLE_HOME
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>

# TODO: Fix: tar: ./rdbms/log/stout_orcl_17338.txt: Cannot stat: No such file or directory
# SOLUTION: Stop DB before collection, or add flag to make tar ignore missing files

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

[ -z "${v_output}" ] && exitError "First parameter is the target file and cannot be null."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."

v_output_fdr="$(cd "$(dirname "${v_output}")"; pwd)"
v_output_file="$(basename "${v_output}")"
v_output_file_noext="${v_output_file%.*}"

v_output_full="${v_output_fdr}/${v_output_file}"
v_output_error="${v_output_fdr}/${v_output_file_noext}.err"

[ -f "${v_output_error}" ] && rm -f "${v_output_error}"

echo "Generating ORACLE_HOME non-binary files list. Please wait.." 

cd "$ORACLE_HOME"

set +e # grep may return "Permission denied"
find -type f -not -path "./.patch_storage/*" -not -name "tfa_setup" -print0 2>> "${v_output_error}" | xargs -0 grep -Il '.' 2>> "${v_output_error}" | tar -czf "${v_output_full}" -T -

[ -f "${v_output_error}" ] && echo "Total errors detected: $(wc -l < "${v_output_error}")"

exit 0