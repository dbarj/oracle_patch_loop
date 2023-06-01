#!/bin/bash
# Script to collect all info needed for ORAdiff
# Created by Rodrigo Jorge <http://www.dbarj.com.br/>
# v1.0.0.5

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

##################
# Check dump user
v_dump_user='hash'

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

echo "Checking if common user. Please wait.."
v_common_user=$($ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" @get_user_prefix.sql)
[ -n "${v_common_user}" ] && v_dump_user="${v_common_user}${v_dump_user}"
##################

# Check if ORADIFF_ONE_DUMP was exported
[ "$ORADIFF_ONE_DUMP" == "0" ] && v_one_dump=0 || v_one_dump=1

v_file=bugs_${v_pattern}.txt
sh "${v_thisdir}/bugsGet.sh" ${v_file}
[ ${v_one_dump} -eq 0 ] && zip -m ${v_zip} ${v_file}

v_file=sha256sum_${v_pattern}.chk
sh "${v_thisdir}/chksumGet.sh" ${v_file}
[ ${v_one_dump} -eq 0 ] && zip -m ${v_zip} ${v_file}

v_file=txtcol_${v_pattern}.tar.gz
sh "${v_thisdir}/fileGet.sh" ${v_file}
[ ${v_one_dump} -eq 0 ] && zip -m ${v_zip} ${v_file}

v_file=symbols_${v_pattern}.csv
sh "${v_thisdir}/symbolGet.sh" ${v_file}
[ ${v_one_dump} -eq 0 ] && zip -m ${v_zip} ${v_file}

sh "${v_thisdir}/schemaCreate.sh" ${v_dump_user}

if [ ${v_one_dump} -eq 1 ]
then
  v_file=bugs_${v_pattern}.txt
  sh "${v_thisdir}/bugsLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}

  v_file=sha256sum_${v_pattern}.chk
  sh "${v_thisdir}/chksumLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}

  v_file=txtcol_${v_pattern}.tar.gz
  sh "${v_thisdir}/fileLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}

  v_file=symbols_${v_pattern}.csv
  sh "${v_thisdir}/symbolLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}
fi

sh "${v_thisdir}/dumpCreate.sh" ${v_dump_user} ${v_pattern}.dmp
mv ${v_pattern}.dmp tables_${v_pattern}.dmp
mv ${v_pattern}.log tables_${v_pattern}.log
zip -m ${v_pattern}.zip tables_${v_pattern}.dmp
zip -m ${v_pattern}.zip tables_${v_pattern}.log

echo "Script Finished."

exit 0