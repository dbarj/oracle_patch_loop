#!/bin/bash
# Script to collect all info needed from the DB
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

# Check if DB_EXP_MERGE_DUMP was exported.
# If DB_EXP_MERGE_DUMP=0, then the generated ORACLE_HOME related files (bugs, symbols, chksum, etc) won't be loaded on a table, but added to zip as separate files.
[ "$DB_EXP_MERGE_DUMP" == "0" ] && v_load_file=0 || v_load_file=1

# Check if DB_EXP_GEN_DUMP was exported.
# If DB_EXP_GEN_DUMP=0, then nothing will be exported. Only the schema populated.
[ "$DB_EXP_GEN_DUMP" == "0" ] && v_gen_dump=0 || v_gen_dump=1

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
v_common_user=$($ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" @${v_thisdir}/get_user_prefix.sql)
[ -n "${v_common_user}" ] && v_dump_user="${v_common_user}${v_dump_user}"
##################
v_thisdir_bkp="${v_thisdir}" # REMOVE_IF_ZIP
[ -f "${v_thisdir}/bugsGet.sh" ] && v_sh_from_zip=1 || v_sh_from_zip=0 # REMOVE_IF_ZIP

[ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_bugs_fixed" # REMOVE_IF_ZIP
v_file=bugs_${v_pattern}.txt
sh "${v_thisdir}/bugsGet.sh" ${v_file}
[ ${v_load_file} -eq 0 ] && zip -m ${v_zip} ${v_file}

[ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_filechksum" # REMOVE_IF_ZIP
v_file=sha256sum_${v_pattern}.chk
sh "${v_thisdir}/chksumGet.sh" ${v_file}
[ ${v_load_file} -eq 0 ] && zip -m ${v_zip} ${v_file}

[ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_txtcollection_files" # REMOVE_IF_ZIP
v_file=txtcol_${v_pattern}.tar.gz
sh "${v_thisdir}/fileGet.sh" ${v_file}
[ ${v_load_file} -eq 0 ] && zip -m ${v_zip} ${v_file}

[ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_symbols" # REMOVE_IF_ZIP
v_file=symbols_${v_pattern}.csv
sh "${v_thisdir}/symbolGet.sh" ${v_file}
[ ${v_load_file} -eq 0 ] && zip -m ${v_zip} ${v_file}

v_thisdir="${v_thisdir_bkp}" # REMOVE_IF_ZIP
sh "${v_thisdir}/schemaCreate.sh" ${v_dump_user}

if [ ${v_load_file} -eq 1 ]
then
  [ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_bugs_fixed" # REMOVE_IF_ZIP
  v_file=bugs_${v_pattern}.txt
  sh "${v_thisdir}/bugsLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}

  [ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_filechksum" # REMOVE_IF_ZIP
  v_file=sha256sum_${v_pattern}.chk
  sh "${v_thisdir}/chksumLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}

  [ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_txtcollection_files" # REMOVE_IF_ZIP
  v_file=txtcol_${v_pattern}.tar.gz
  sh "${v_thisdir}/fileLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}

  [ ${v_sh_from_zip} -eq 0 ] && v_thisdir="${v_thisdir_bkp}/../adb_load_symbols" # REMOVE_IF_ZIP
  v_file=symbols_${v_pattern}.csv
  sh "${v_thisdir}/symbolLoad.sh" ${v_dump_user} ${v_file}
  rm -f ${v_file}
fi

v_thisdir="${v_thisdir_bkp}" # REMOVE_IF_ZIP
sh "${v_thisdir}/dictionaryGet.sh" ${v_dump_user}

if [ ${v_gen_dump} -eq 1 ]
then
  sh "${v_thisdir}/dumpCreate.sh" ${v_dump_user} ${v_pattern}.dmp
  mv ${v_pattern}.dmp tables_${v_pattern}.dmp
  mv ${v_pattern}.log tables_${v_pattern}.log
  zip -m ${v_pattern}.zip tables_${v_pattern}.dmp tables_${v_pattern}.log
fi

echo "Script Finished."

exit 0