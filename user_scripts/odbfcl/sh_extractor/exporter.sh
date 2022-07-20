#!/bin/bash
# Script to collect all info needed for ORAdiff
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>
# v1.0.0.2

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

v_pattern="$1"

v_example='19.0.0.0_RU14_20220101'

[ -z "$v_pattern" -o "$#" -ne 1 ] && exitError "Usage: $0 <pattern>

First parameter is the output file name and cannot be null.

Eg: $0 ${v_example}

The output is a zip file.
"

v_pattern_cnt=`awk -F" " '{print NF-1}' <<< "${v_pattern}"`
[ ${v_pattern_cnt} -ne 0 ] && exitError "Pattern \"${v_output}\" must not have any spaces. Eg: ${v_example}"

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

v_zip=${v_pattern}.zip

v_file=bugs_${v_pattern}.txt
sh "${v_thisdir}/bugsGet.sh" ${v_file}
zip -m ${v_zip} ${v_file}

v_file=sha256sum_${v_pattern}.chk
sh "${v_thisdir}/fileGet.sh" ${v_file}
zip -m ${v_zip} ${v_file}

v_file=txtcol_${v_pattern}.tar.gz
sh "${v_thisdir}/fileCollect.sh" ${v_file}
zip -m ${v_zip} ${v_file}

v_file=symbols_${v_pattern}.csv
sh "${v_thisdir}/symbolGet.sh" ${v_file}
zip -m ${v_zip} ${v_file}

sh "${v_thisdir}/dumpCreate.sh" ${v_pattern}.dmp
mv ${v_pattern}.dmp tables_${v_pattern}.dmp
mv ${v_pattern}.log tables_${v_pattern}.log
zip -m ${v_pattern}.zip tables_${v_pattern}.dmp
zip -m ${v_pattern}.zip tables_${v_pattern}.log

exit 0