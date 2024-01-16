#!/bin/bash
# Script to get the sha256sum of all ORACLE_HOME files and libraries
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
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."

v_output_fdr="$(cd "$(dirname "${v_output}")"; pwd)"
v_output_file="$(basename "${v_output}")"
v_output_file_noext="${v_output_file%.*}"

v_output_full="${v_output_fdr}/${v_output_file}"
v_output_error="${v_output_fdr}/${v_output_file_noext}.err"

[ -f "${v_output_error}" ] && rm -f "${v_output_error}"

echo "Generating sha256sum for \$ORACLE_HOME files. Please wait.." 

cd "$ORACLE_HOME"
set +e
find -type f -exec sha256sum "{}" + > "${v_output_full}" 2>> "${v_output_error}"
set -eo pipefail
cd - > /dev/null

sed -i 's/$/  F/' "${v_output_full}"

set +e
v_libs=$(find "$ORACLE_HOME" -type f -name "*.a" 2>> "${v_output_error}")
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
  ar x "${v_lib}" 2>> "${v_output_error}"
  set -eo pipefail
  find -type f -exec sha256sum "{}" + > "${v_out_file}"
  cd - > /dev/null
  sed -i "s|  \.|  ${v_lib}|" "${v_out_file}"
  sed -i 's/$/  L/' "${v_out_file}"
  cat "${v_out_file}" >> "${v_output}"
  rm -rf "${v_ext_fold}" "${v_out_file}"
done

[ -f "${v_output_error}" ] && echo "Total errors detected: $(wc -l < "${v_output_error}")"

exit 0