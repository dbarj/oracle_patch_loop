#!/bin/bash
# Script to get the sha256sum of all ORACLE_HOME files and libraries
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

echo "Generating sha256sum for \$ORACLE_HOME files. Please wait.." 

cd "$ORACLE_HOME"
set +e
find -type f -exec sha256sum "{}" + > "${v_out_file_full}" 2>> "${v_err_file_full}"
set -eo pipefail
cd - > /dev/null

sed -i 's/$/  F/' "${v_out_file_full}"

set +e
v_libs=$(find "$ORACLE_HOME" -type f -name "*.a" 2>> "${v_err_file_full}")
set -eo pipefail

v_ext_fold=`mktemp -d`
v_out_file=`mktemp`

echo "Generating sha256sum for static libs. Please wait.." 

IFS=$'\n'
for v_lib in ${v_libs}
do
  rm -rf "${v_ext_fold}"
  mkdir "${v_ext_fold}"
  cd "${v_ext_fold}"
  set +e
  ar x "${v_lib}" 2>> "${v_err_file_full}"
  set -eo pipefail
  find -type f -exec sha256sum "{}" + > "${v_out_file}"
  cd - > /dev/null
  sed -i "s|  \.|  ${v_lib}|" "${v_out_file}"
  sed -i 's/$/  L/' "${v_out_file}"
  cat "${v_out_file}" >> "${v_out_file_param}"
  rm -rf "${v_ext_fold}" "${v_out_file}"
done

[ -f "${v_err_file_full}" ] && echo "Total errors detected: $(wc -l < "${v_err_file_full}")"

exit 0