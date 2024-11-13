#!/bin/bash
# Script to collect all info needed from the DB

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

echoDebug ()
{
  if [ "$DEBUG" = "1" ]
  then
    echo "$1"
  fi
}

v_pattern="$1"

v_example='19.0.0.0_RU14_20220101'

# Defaults
v_def_load_file='true'
v_def_gen_dump='true'
v_def_ignore_error='true'
v_def_sysdba_connect='/ as sysdba'
v_def_dump_user_name='hash'
v_def_dump_user_pass='HhAaSsHh..135'
v_def_dump_user_tbs='USERS'
v_def_dump_user_temp='TEMP'
v_def_dump_exp_dir='expdir_hash'
v_def_dump_exp_comp='false'
v_def_dump_int_only='true'

[ -z "$v_pattern" -o "$#" -ne 1 ] && exitError "Usage: $0 <pattern>

First parameter is the output file name and cannot be null.

Eg: $0 ${v_example}

The output is a zip file.

Environment Variables:

  DB_EXP_MERGE_DUMP

      The generated ORACLE_HOME related files (bugs, symbols, chksum, etc)
      will be loaded on DB tables, not added to zip as separate files.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_load_file}'

  DB_EXP_GEN_DUMP

      If schema is exported after being populated.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_gen_dump}'

  DB_EXP_IGNORE_ERROR

      Code will ignore critical errors.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_ignore_error}'

  DB_EXP_CRED

      SQL*Plus connect string.

      Default value: '${v_def_sysdba_connect}'

  DB_EXP_USER

      Schema inside the database that will temporarily hold the oradiff data.

      Default value: '${v_def_dump_user_name}'

  DB_EXP_USER_PASS

      Password for the temporary schema that will temporarily hold the oradiff data.

      Default value: '${v_def_dump_user_pass}'

  DB_EXP_USER_TBS

      Default permanent tablespace for the temporary schema.

      Default value: '${v_def_dump_user_tbs}'

  DB_EXP_USER_TEMP

      Default temp tablespace for the temporary schema.

      Default value: '${v_def_dump_user_temp}'

  DB_EXP_DIRECTORY

      Temporary directory that will be created to export the genetared data.
      Only valid when DB_EXP_GEN_DUMP=true.

      Default value: '${v_def_dump_exp_dir}'

  DB_EXP_COMPRESS

      Enable data pump compression.
      (Requires licensing of the Oracle Advanced Compression option).
      Only valid when DB_EXP_GEN_DUMP=true.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_dump_exp_comp}'

  DB_EXP_INTERNAL_ONLY

      If we want to retrieve dictionary info of full database or just internal
      oracle maintained schemas.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_dump_int_only}'


"

###################
# Check variables #
###################

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_MERGE_DUMP=false, then the generated ORACLE_HOME related files (bugs, symbols, chksum, etc) won't be loaded on DB tables, but added to zip as separate files.
if [ -z "$DB_EXP_MERGE_DUMP" ]
then
  v_load_file=${v_def_load_file}
  echoDebug "Note: Variable 'DB_EXP_MERGE_DUMP' was not exported. Assigning DB_EXP_MERGE_DUMP=${v_load_file} (default)."
else
  v_load_file=$(echo "${DB_EXP_MERGE_DUMP}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_MERGE_DUMP=${v_load_file} (provided)."
fi

if [ "${v_load_file}" != "false" -a "${v_load_file}" != "true" ]
then
  exitError "DB_EXP_MERGE_DUMP must be 'true' or 'false'."
fi

# If DB_EXP_GEN_DUMP=false, then nothing will be exported. Only the schema populated.
if [ -z "$DB_EXP_GEN_DUMP" ]
then
  v_gen_dump=${v_def_gen_dump}
  echoDebug "Note: Variable 'DB_EXP_GEN_DUMP' was not exported. Assigning DB_EXP_GEN_DUMP=${v_gen_dump} (default)."
else
  v_gen_dump=$(echo "${DB_EXP_GEN_DUMP}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_GEN_DUMP=${v_gen_dump} (provided)."
fi

if [ "${v_gen_dump}" != "false" -a "${v_gen_dump}" != "true" ]
then
  exitError "DB_EXP_GEN_DUMP must be 'true' or 'false'."
fi

# If DB_EXP_IGNORE_ERROR=false, the code will stop on some critical errors.
if [ -z "$DB_EXP_IGNORE_ERROR" ]
then
  v_ignore_error=${v_def_ignore_error}
  echoDebug "Note: Variable 'DB_EXP_IGNORE_ERROR' was not exported. Assigning DB_EXP_IGNORE_ERROR=${v_ignore_error} (default)."
else
  v_ignore_error=$(echo "${DB_EXP_IGNORE_ERROR}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_IGNORE_ERROR=${v_ignore_error} (provided)."
fi

if [ "${v_ignore_error}" != "false" -a "${v_ignore_error}" != "true" ]
then
  exitError "DB_EXP_IGNORE_ERROR must be 'true' or 'false'."
fi

# If DB_EXP_CRED is exported, then connect using this string instead of '/ as sysdba'.
if [ -z "$DB_EXP_CRED" ]
then
  v_sysdba_connect=${v_def_sysdba_connect}
  # To be used by child shells.
  DB_EXP_CRED=${v_sysdba_connect}
  export DB_EXP_CRED
  echoDebug "Note: Variable 'DB_EXP_CRED' was not exported. Assigning DB_EXP_CRED='${v_sysdba_connect}' (default)."
else
  v_sysdba_connect="${DB_EXP_CRED}"
  echo "Note: DB_EXP_CRED (provided)."
fi

# If DB_EXP_USER defines the user inside the database to export the oradiff data.
if [ -z "$DB_EXP_USER" ]
then
  v_dump_user_name=${v_def_dump_user_name}
  echoDebug "Note: Variable 'DB_EXP_USER' was not exported. Assigning DB_EXP_USER='${v_dump_user_name}' (default)."
else
  v_dump_user_name=$(echo "${v_dump_user_name}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_USER (provided)."
fi

# If DB_EXP_USER_PASS defines the user password inside the database to export the oradiff data.
if [ -z "$DB_EXP_USER_PASS" ]
then
  # To be used by child shells.
  DB_EXP_USER_PASS=${v_def_dump_user_pass}
  export DB_EXP_USER_PASS
  echoDebug "Note: Variable 'DB_EXP_USER_PASS' was not exported. Assigning DB_EXP_USER_PASS='${v_def_dump_user_pass}' (default)."
else
  echo "Note: DB_EXP_USER_PASS (provided)."
fi

# If DB_EXP_USER_TBS defines the user tablespace inside the database to export the oradiff data.
if [ -z "$DB_EXP_USER_TBS" ]
then
  # To be used by child shells.
  DB_EXP_USER_TBS=${v_def_dump_user_tbs}
  export DB_EXP_USER_TBS
  echoDebug "Note: Variable 'DB_EXP_USER_TBS' was not exported. Assigning DB_EXP_USER_TBS='${DB_EXP_USER_TBS}' (default)."
else
  echo "Note: DB_EXP_USER_TBS (provided)."
fi

# If DB_EXP_USER_TEMP defines the user temp tablespace inside the database to export the oradiff data.
if [ -z "$DB_EXP_USER_TEMP" ]
then
  # To be used by child shells.
  DB_EXP_USER_TEMP=${v_def_dump_user_temp}
  export DB_EXP_USER_TEMP
  echoDebug "Note: Variable 'DB_EXP_USER_TEMP' was not exported. Assigning DB_EXP_USER_TEMP='${DB_EXP_USER_TEMP}' (default)."
else
  echo "Note: DB_EXP_USER_TEMP (provided)."
fi

# If DB_EXP_DIRECTORY defines the directory name inside the database to export the oradiff data.
if [ -z "$DB_EXP_DIRECTORY" ]
then
  # To be used by child shells.
  DB_EXP_DIRECTORY=${v_def_dump_exp_dir}
  export DB_EXP_DIRECTORY
  echoDebug "Note: Variable 'DB_EXP_DIRECTORY' was not exported. Assigning DB_EXP_DIRECTORY='${DB_EXP_DIRECTORY}' (default)."
else
  echo "Note: DB_EXP_DIRECTORY (provided)."
fi

# If DB_EXP_COMPRESS defines if compression can be used to export the oradiff data.
if [ -z "$DB_EXP_COMPRESS" ]
then
  # To be used by child shells.
  DB_EXP_COMPRESS=${v_def_dump_exp_comp}
  export DB_EXP_COMPRESS
  echoDebug "Note: Variable 'DB_EXP_COMPRESS' was not exported. Assigning DB_EXP_COMPRESS='${DB_EXP_COMPRESS}' (default)."
else
  echo "Note: DB_EXP_COMPRESS (provided)."
fi

if [ "${DB_EXP_COMPRESS}" != "false" -a "${DB_EXP_COMPRESS}" != "true" ]
then
  exitError "DB_EXP_COMPRESS must be 'true' or 'false'."
fi

# If DB_EXP_INTERNAL_ONLY defines if we filter for internal schemas during export of oradiff data.
if [ -z "$DB_EXP_INTERNAL_ONLY" ]
then
  # To be used by child shells.
  DB_EXP_INTERNAL_ONLY=${v_def_dump_int_only}
  export DB_EXP_INTERNAL_ONLY
  echoDebug "Note: Variable 'DB_EXP_INTERNAL_ONLY' was not exported. Assigning DB_EXP_INTERNAL_ONLY='${DB_EXP_INTERNAL_ONLY}' (default)."
else
  echo "Note: DB_EXP_INTERNAL_ONLY (provided)."
fi

if [ "${DB_EXP_INTERNAL_ONLY}" != "false" -a "${DB_EXP_INTERNAL_ONLY}" != "true" ]
then
  exitError "DB_EXP_INTERNAL_ONLY must be 'true' or 'false'."
fi

# Check if v_dump_user_name is the default. If it is, we drop it before and after.
if [ "$v_def_dump_user_name" = "$v_dump_user_name" ]
then
  v_drop_dump_user=true
else
  v_drop_dump_user=false
fi

v_pattern_cnt=`awk -F" " '{print NF-1}' <<< "${v_pattern}"`
[ ${v_pattern_cnt} -ne 0 ] && exitError "Pattern \"${v_output}\" must not have any spaces. Eg: ${v_example}"

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

v_zip=${v_pattern}.zip

########################
# Define dump username #
########################

echo "Checking if common user. Please wait.."
v_common_user=$($ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" @${v_thisdir}/get_user_prefix.sql) && v_ret=$? || v_ret=$?

if [ $v_ret -ne 0 ]
then
  echoError "Failed to get required information."
  exitError "${v_common_user}"
fi

if [ "$v_def_dump_user_name" = "$v_dump_user_name" ]
then
  [ -n "${v_common_user}" ] && v_dump_user_name="${v_common_user}${v_dump_user_name}"
fi

##############
# Start Code #
##############

v_thisdir_bkp="${v_thisdir}" # REMOVE_IF_ZIP

v_thisdir="${v_thisdir_bkp}/../adb_load_bugs_fixed" # REMOVE_IF_ZIP
v_file=bugs_${v_pattern}.txt
sh "${v_thisdir}/bugsGet.sh" ${v_file} && v_bugs_ret=$? || v_bugs_ret=$?
if ! ${v_ignore_error} && [ ${v_bugs_ret} -ne 0 ]
then
  exitError "OPatch returned ${v_bugs_ret}."
fi
! ${v_load_file} && zip -m ${v_zip} ${v_file}

v_thisdir="${v_thisdir_bkp}/../adb_load_filechksum" # REMOVE_IF_ZIP
v_file=sha256sum_${v_pattern}.chk
sh "${v_thisdir}/chksumGet.sh" ${v_file}
! ${v_load_file} && zip -m ${v_zip} ${v_file}

v_thisdir="${v_thisdir_bkp}/../adb_load_txtcollection_files" # REMOVE_IF_ZIP
v_file=txtcol_${v_pattern}.tar.gz
sh "${v_thisdir}/fileGet.sh" ${v_file}
! ${v_load_file} && zip -m ${v_zip} ${v_file}

v_thisdir="${v_thisdir_bkp}/../adb_load_symbols" # REMOVE_IF_ZIP
v_file=symbols_${v_pattern}.csv
sh "${v_thisdir}/symbolGet.sh" ${v_file}
! ${v_load_file} && zip -m ${v_zip} ${v_file}

v_thisdir="${v_thisdir_bkp}" # REMOVE_IF_ZIP
sh "${v_thisdir}/schemaCreate.sh" ${v_dump_user_name} ${v_drop_dump_user}

if ${v_load_file}
then
  if [ ${v_bugs_ret} -eq 0 ]
  then
    v_thisdir="${v_thisdir_bkp}/../adb_load_bugs_fixed" # REMOVE_IF_ZIP
    v_file=bugs_${v_pattern}.txt
    sh "${v_thisdir}/bugsLoad.sh" ${v_dump_user_name} ${v_file}
    rm -f ${v_file}
  fi

  v_thisdir="${v_thisdir_bkp}/../adb_load_filechksum" # REMOVE_IF_ZIP
  v_file=sha256sum_${v_pattern}.chk
  sh "${v_thisdir}/chksumLoad.sh" ${v_dump_user_name} ${v_file}
  rm -f ${v_file}

  v_thisdir="${v_thisdir_bkp}/../adb_load_txtcollection_files" # REMOVE_IF_ZIP
  v_file=txtcol_${v_pattern}.tar.gz
  sh "${v_thisdir}/fileLoad.sh" ${v_dump_user_name} ${v_file}
  rm -f ${v_file}

  v_thisdir="${v_thisdir_bkp}/../adb_load_symbols" # REMOVE_IF_ZIP
  v_file=symbols_${v_pattern}.csv
  sh "${v_thisdir}/symbolLoad.sh" ${v_dump_user_name} ${v_file}
  rm -f ${v_file}
fi

v_thisdir="${v_thisdir_bkp}" # REMOVE_IF_ZIP
sh "${v_thisdir}/dictionaryGet.sh" ${v_dump_user_name}

if ${v_gen_dump}
then
  sh "${v_thisdir}/dumpCreate.sh" ${v_dump_user_name} tables_${v_pattern}.dmp ${v_drop_dump_user}
  set +e
  zip -m ${v_pattern}.zip tables_${v_pattern}.dmp tables_${v_pattern}.log
  v_ret=$?
  set -eo pipefail
  if [ $v_ret -ne 0 ]
  then
    echoError "Script failed to zip tables_${v_pattern}.dmp in ${v_pattern}.zip". 
    v_file_user=$(stat -c '%U' tables_${v_pattern}.dmp)
    echoError "1 - Try to rerun as '${v_file_user}' user." 
    echoError "2 - Check file 'tables_${v_pattern}.dmp' permissions, make it readeable and run:". 
    echoError "$ zip ${v_pattern}.zip tables_${v_pattern}.dmp"
    exit $v_ret
  fi
fi

echo "Script Finished."

exit 0