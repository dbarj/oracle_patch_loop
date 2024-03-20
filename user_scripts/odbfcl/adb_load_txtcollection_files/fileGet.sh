#!/bin/bash
# Script to get all non-binary files in ORACLE_HOME
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>

# TODO: Fix: tar: ./rdbms/log/stout_orcl_17338.txt: Cannot stat: No such file or directory
# SOLUTION: Stop DB before collection, or add flag to make tar ignore missing files

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

v_out_file_param="$1"

[ -z "${v_out_file_param}" ] && exitError "First parameter is the target file and cannot be null."
[ -f "${v_out_file_param}" ] && exitError "File \"${v_out_file_param}\" already exists. Remove it before rerunning."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."

v_out_file_fdr="$(cd "$(dirname "${v_out_file_param}")"; pwd)"
v_out_file_name="$(basename "${v_out_file_param}")"
v_out_file_name_noext="${v_out_file_name%.*}"

v_out_file_full="${v_out_file_fdr}/${v_out_file_name}"
v_err_file_full="${v_out_file_fdr}/${v_out_file_name_noext}.err"

[ -f "${v_err_file_full}" ] && rm -f "${v_err_file_full}"

echo "Generating ORACLE_HOME non-binary files list. Please wait.." 

cd "$ORACLE_HOME"

set +e # grep may return "Permission denied"
find -type f -not -path "./.patch_storage/*" -not -name "tfa_setup" -print0 2>> "${v_err_file_full}" | xargs -0 grep -Il '.' 2>> "${v_err_file_full}" | tar -czf "${v_out_file_full}" -T -

[ -f "${v_err_file_full}" ] && echo "Total errors detected: $(wc -l < "${v_err_file_full}")"

exit 0