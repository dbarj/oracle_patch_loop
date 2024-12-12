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

v_example='MYDB'

# Defaults
v_def_load_file='true'
v_def_gen_dump='true'
v_def_ignore_error='true'
v_def_verbose='false'
v_def_sysdba_connect='/ as sysdba'
v_def_dump_user_name='hash'
v_def_dump_user_pass='HhAaSsHh..135'
v_def_dump_user_tbs='USERS'
v_def_dump_user_temp='TEMP'
v_def_dump_exp_dir='expdir_hash'
v_def_dump_exp_comp='false'
v_def_dump_int_only='true'

[ -z "$v_pattern" -o "$#" -ne 1 -o "$v_pattern" = "-help" ] && echoError "Usage: $0 <pattern> | -help

First parameter is the output file name and cannot be null.

ORAdiff exporter will collect all metadata information from the database,
to be loaded in the ORAdiff utility for comparison with another patch set,
including another custom patch set you already loaded.

Example:
 
  \$ $0 ${v_example}

  The output will be a zip file named '${v_example}.zip'.
"

[ -z "$v_pattern" -o "$#" -ne 1 ] && echoError "The behaviour of the ORAdiff exporter can be changed by exporting
some environment variables. (Use -help for more details)"

[ "$v_pattern" = "-help" ] && echoError "The behaviour of the ORAdiff exporter can be changed by exporting
some environment variables described below.

Environment Variables:

  DB_EXP_GEN_DUMP

      If ORAdiff schema is exported after being populated. If set to false,
      the code will only populate the DB schema and stop.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_gen_dump}'

  DB_EXP_IGNORE_ERROR

      Code will ignore critical errors and move forward.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_ignore_error}'

  DB_EXP_CONN

      SQL*Plus connect string.

      Default value: '${v_def_sysdba_connect}'

  DB_EXP_USER

      Schema inside the database that will temporarily hold the ORAdiff data
      before it is exported.

      Default value: '${v_def_dump_user_name}'

  DB_EXP_USER_PASS

      Password for the temporary ORAdiff schema.

      Default value: '${v_def_dump_user_pass}'

  DB_EXP_USER_TBS

      Default permanent tablespace for the temporary ORAdiff schema.

      Default value: '${v_def_dump_user_tbs}'

  DB_EXP_USER_TEMP

      Default temp tablespace for the temporary ORAdiff schema.

      Default value: '${v_def_dump_user_temp}'

  DB_EXP_DIRECTORY

      Temporary directory that will be created to export the genetared data.
      Only applicable when DB_EXP_GEN_DUMP=true.

      Default value: '${v_def_dump_exp_dir}'

  DB_EXP_COMPRESS

      Enable data pump compression.
      (Requires licensing of the Oracle Advanced Compression option).
      Only valid when DB_EXP_GEN_DUMP=true.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_dump_exp_comp}'

  DB_EXP_INTERNAL_ONLY

      Retrieve dictionary info of all DB schemas or just internal
      oracle maintained schemas. If 'true', will also skip collecting
      ORACLE_HOME files and symbols.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_dump_int_only}'

  DB_EXP_MERGE_DUMP

      The generated ORACLE_HOME related files (bugs, symbols, chksum, etc)
      will be loaded on DB tables, not added to zip as separate files.

      Accepted values: 'true' or 'false'.
      Default value: '${v_def_load_file}'

"

[ -z "$v_pattern" -o "$#" -ne 1 -o "$v_pattern" = "-help" ] && exit 1

###################
# Check variables #
###################

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

# If DB_EXP_MERGE_DUMP=false, then the generated ORACLE_HOME related files (bugs, symbols, chksum, etc) won't be loaded on DB tables, but added to zip as separate files.
if [ -z "$DB_EXP_MERGE_DUMP" ]
then
  DB_EXP_MERGE_DUMP=${v_def_load_file}
  echoDebug "Note: Variable 'DB_EXP_MERGE_DUMP' was not exported. Assigning DB_EXP_MERGE_DUMP=${DB_EXP_MERGE_DUMP} (default)."
else
  DB_EXP_MERGE_DUMP=$(echo "${DB_EXP_MERGE_DUMP}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_MERGE_DUMP=${DB_EXP_MERGE_DUMP} (provided)."
fi

if [ "${DB_EXP_MERGE_DUMP}" != "false" -a "${DB_EXP_MERGE_DUMP}" != "true" ]
then
  exitError "DB_EXP_MERGE_DUMP must be 'true' or 'false'."
fi

# If DB_EXP_GEN_DUMP=false, then nothing will be exported. Only the schema populated.
if [ -z "$DB_EXP_GEN_DUMP" ]
then
  DB_EXP_GEN_DUMP=${v_def_gen_dump}
  echoDebug "Note: Variable 'DB_EXP_GEN_DUMP' was not exported. Assigning DB_EXP_GEN_DUMP=${DB_EXP_GEN_DUMP} (default)."
else
  DB_EXP_GEN_DUMP=$(echo "${DB_EXP_GEN_DUMP}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_GEN_DUMP=${DB_EXP_GEN_DUMP} (provided)."
fi

if [ "${DB_EXP_GEN_DUMP}" != "false" -a "${DB_EXP_GEN_DUMP}" != "true" ]
then
  exitError "DB_EXP_GEN_DUMP must be 'true' or 'false'."
fi

# If DB_EXP_IGNORE_ERROR=false, the code will stop on some critical errors.
if [ -z "$DB_EXP_IGNORE_ERROR" ]
then
  DB_EXP_IGNORE_ERROR=${v_def_ignore_error}
  echoDebug "Note: Variable 'DB_EXP_IGNORE_ERROR' was not exported. Assigning DB_EXP_IGNORE_ERROR=${DB_EXP_IGNORE_ERROR} (default)."
else
  DB_EXP_IGNORE_ERROR=$(echo "${DB_EXP_IGNORE_ERROR}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_IGNORE_ERROR=${DB_EXP_IGNORE_ERROR} (provided)."
fi

if [ "${DB_EXP_IGNORE_ERROR}" != "false" -a "${DB_EXP_IGNORE_ERROR}" != "true" ]
then
  exitError "DB_EXP_IGNORE_ERROR must be 'true' or 'false'."
fi

# If DB_EXP_VERBOSE=true, the code will print detailed steps.
if [ -z "$DB_EXP_VERBOSE" ]
then
  DB_EXP_VERBOSE=${v_def_ignore_error}
  echoDebug "Note: Variable 'DB_EXP_VERBOSE' was not exported. Assigning DB_EXP_VERBOSE=${DB_EXP_VERBOSE} (default)."
else
  DB_EXP_VERBOSE=$(echo "${DB_EXP_VERBOSE}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_VERBOSE=${DB_EXP_VERBOSE} (provided)."
fi

if [ "${DB_EXP_VERBOSE}" != "false" -a "${DB_EXP_VERBOSE}" != "true" ]
then
  exitError "DB_EXP_VERBOSE must be 'true' or 'false'."
fi

# If DB_EXP_CONN is exported, then connect using this string instead of '/ as sysdba'.
if [ -z "$DB_EXP_CONN" ]
then
  # To be used by child shells.
  DB_EXP_CONN=${v_def_sysdba_connect}
  export DB_EXP_CONN
  echoDebug "Note: Variable 'DB_EXP_CONN' was not exported. Assigning DB_EXP_CONN='${DB_EXP_CONN}' (default)."
else
  DB_EXP_CONN="${DB_EXP_CONN}"
  echo "Note: DB_EXP_CONN (provided)."
fi

# If DB_EXP_USER defines the user inside the database to export the ORAdiff data.
if [ -z "$DB_EXP_USER" ]
then
  DB_EXP_USER=${v_def_dump_user_name}
  export DB_EXP_USER
  echoDebug "Note: Variable 'DB_EXP_USER' was not exported. Assigning DB_EXP_USER='${DB_EXP_USER}' (default)."
else
  DB_EXP_USER=$(echo "${DB_EXP_USER}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_USER (provided)."
fi

# If DB_EXP_USER_PASS defines the user password inside the database to export the ORAdiff data.
if [ -z "$DB_EXP_USER_PASS" ]
then
  # To be used by child shells.
  DB_EXP_USER_PASS=${v_def_dump_user_pass}
  export DB_EXP_USER_PASS
  echoDebug "Note: Variable 'DB_EXP_USER_PASS' was not exported. Assigning DB_EXP_USER_PASS='${v_def_dump_user_pass}' (default)."
else
  echo "Note: DB_EXP_USER_PASS (provided)."
fi

# If DB_EXP_USER_TBS defines the user tablespace inside the database to export the ORAdiff data.
if [ -z "$DB_EXP_USER_TBS" ]
then
  # To be used by child shells.
  DB_EXP_USER_TBS=${v_def_dump_user_tbs}
  export DB_EXP_USER_TBS
  echoDebug "Note: Variable 'DB_EXP_USER_TBS' was not exported. Assigning DB_EXP_USER_TBS='${DB_EXP_USER_TBS}' (default)."
else
  echo "Note: DB_EXP_USER_TBS (provided)."
fi

# If DB_EXP_USER_TEMP defines the user temp tablespace inside the database to export the ORAdiff data.
if [ -z "$DB_EXP_USER_TEMP" ]
then
  # To be used by child shells.
  DB_EXP_USER_TEMP=${v_def_dump_user_temp}
  export DB_EXP_USER_TEMP
  echoDebug "Note: Variable 'DB_EXP_USER_TEMP' was not exported. Assigning DB_EXP_USER_TEMP='${DB_EXP_USER_TEMP}' (default)."
else
  echo "Note: DB_EXP_USER_TEMP (provided)."
fi

# If DB_EXP_DIRECTORY defines the directory name inside the database to export the ORAdiff data.
if [ -z "$DB_EXP_DIRECTORY" ]
then
  # To be used by child shells.
  DB_EXP_DIRECTORY=${v_def_dump_exp_dir}
  export DB_EXP_DIRECTORY
  echoDebug "Note: Variable 'DB_EXP_DIRECTORY' was not exported. Assigning DB_EXP_DIRECTORY='${DB_EXP_DIRECTORY}' (default)."
else
  echo "Note: DB_EXP_DIRECTORY (provided)."
fi

# If DB_EXP_COMPRESS defines if compression can be used to export the ORAdiff data.
if [ -z "$DB_EXP_COMPRESS" ]
then
  # To be used by child shells.
  DB_EXP_COMPRESS=${v_def_dump_exp_comp}
  export DB_EXP_COMPRESS
  echoDebug "Note: Variable 'DB_EXP_COMPRESS' was not exported. Assigning DB_EXP_COMPRESS='${DB_EXP_COMPRESS}' (default)."
else
  DB_EXP_COMPRESS=$(echo "${DB_EXP_COMPRESS}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_COMPRESS (provided)."
fi

if [ "${DB_EXP_COMPRESS}" != "false" -a "${DB_EXP_COMPRESS}" != "true" ]
then
  exitError "DB_EXP_COMPRESS must be 'true' or 'false'."
fi

# If DB_EXP_INTERNAL_ONLY defines if we filter for internal schemas during export of ORAdiff data.
if [ -z "$DB_EXP_INTERNAL_ONLY" ]
then
  # To be used by child shells.
  DB_EXP_INTERNAL_ONLY=${v_def_dump_int_only}
  export DB_EXP_INTERNAL_ONLY
  echoDebug "Note: Variable 'DB_EXP_INTERNAL_ONLY' was not exported. Assigning DB_EXP_INTERNAL_ONLY='${DB_EXP_INTERNAL_ONLY}' (default)."
else
  DB_EXP_INTERNAL_ONLY=$(echo "${DB_EXP_INTERNAL_ONLY}" | tr '[:upper:]' '[:lower:]')
  echo "Note: DB_EXP_INTERNAL_ONLY (provided)."
fi

if [ "${DB_EXP_INTERNAL_ONLY}" != "false" -a "${DB_EXP_INTERNAL_ONLY}" != "true" ]
then
  exitError "DB_EXP_INTERNAL_ONLY must be 'true' or 'false'."
fi

# Check if DB_EXP_USER is the default. If it is, we drop it before and after.
if [ "$v_def_dump_user_name" = "$DB_EXP_USER" ]
then
  v_drop_dump_user=true
else
  v_drop_dump_user=false
fi

v_pattern_cnt=`awk -F" " '{print NF-1}' <<< "${v_pattern}"`
[ ${v_pattern_cnt} -ne 0 ] && exitError "Pattern \"${v_output}\" must not have any spaces. Eg: ${v_example}"

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

v_zip="${v_pattern}.zip"

########################
# Define dump username #
########################

echo "Checking if common user. Please wait.."
v_common_user=$($ORACLE_HOME/bin/sqlplus -L -S "${DB_EXP_CONN}" @${v_thisdir}/get_user_prefix.sql) && v_ret=$? || v_ret=$?

if [ $v_ret -ne 0 ]
then
  echoError "Failed to get required information."
  exitError "${v_common_user}"
fi

if [ "$v_def_dump_user_name" = "$DB_EXP_USER" ]
then
  [ -n "${v_common_user}" ] && DB_EXP_USER="${v_common_user}${DB_EXP_USER}"
fi

##############
# Start Code #
##############

v_thisdir_bkp="${v_thisdir}" # REMOVE_IF_ZIP

v_thisdir="${v_thisdir_bkp}/../adb_load_bugs_fixed" # REMOVE_IF_ZIP
v_file=bugs_${v_pattern}.txt
sh "${v_thisdir}/bugsGet.sh" "${v_file}" && v_bugs_ret=$? || v_bugs_ret=$?
if ! ${DB_EXP_IGNORE_ERROR} && [ ${v_bugs_ret} -ne 0 ]
then
  exitError "OPatch returned ${v_bugs_ret}."
fi
! ${DB_EXP_MERGE_DUMP} && zip -m "${v_zip}" "${v_file}"

v_thisdir="${v_thisdir_bkp}/../adb_load_filechksum" # REMOVE_IF_ZIP
v_file=sha256sum_${v_pattern}.chk
sh "${v_thisdir}/chksumGet.sh" "${v_file}"
! ${DB_EXP_MERGE_DUMP} && zip -m "${v_zip}" "${v_file}"

if ! ${DB_EXP_INTERNAL_ONLY}
then
  v_thisdir="${v_thisdir_bkp}/../adb_load_txtcollection_files" # REMOVE_IF_ZIP
  v_file=txtcol_${v_pattern}.tar.gz
  sh "${v_thisdir}/fileGet.sh" "${v_file}"
  ! ${DB_EXP_MERGE_DUMP} && zip -m "${v_zip}" "${v_file}"

  v_thisdir="${v_thisdir_bkp}/../adb_load_symbols" # REMOVE_IF_ZIP
  v_file=symbols_${v_pattern}.csv
  sh "${v_thisdir}/symbolGet.sh" "${v_file}"
  ! ${DB_EXP_MERGE_DUMP} && zip -m "${v_zip}" "${v_file}"
fi

v_thisdir="${v_thisdir_bkp}" # REMOVE_IF_ZIP
sh "${v_thisdir}/schemaCreate.sh" "${DB_EXP_USER}" "${v_drop_dump_user}"

if ${DB_EXP_MERGE_DUMP}
then
  if [ ${v_bugs_ret} -eq 0 ]
  then
    v_thisdir="${v_thisdir_bkp}/../adb_load_bugs_fixed" # REMOVE_IF_ZIP
    v_file="bugs_${v_pattern}.txt"
    sh "${v_thisdir}/bugsLoad.sh" "${DB_EXP_USER}" "${v_file}"
    rm -f "${v_file}"
  fi

  v_thisdir="${v_thisdir_bkp}/../adb_load_filechksum" # REMOVE_IF_ZIP
  v_file="sha256sum_${v_pattern}.chk"
  sh "${v_thisdir}/chksumLoad.sh" "${DB_EXP_USER}" "${v_file}"
  rm -f "${v_file}"

  if ! ${DB_EXP_INTERNAL_ONLY}
  then
    v_thisdir="${v_thisdir_bkp}/../adb_load_txtcollection_files" # REMOVE_IF_ZIP
    v_file="txtcol_${v_pattern}.tar.gz"
    sh "${v_thisdir}/fileLoad.sh" "${DB_EXP_USER}" "${v_file}"
    rm -f "${v_file}"

    v_thisdir="${v_thisdir_bkp}/../adb_load_symbols" # REMOVE_IF_ZIP
    v_file="symbols_${v_pattern}.csv"
    sh "${v_thisdir}/symbolLoad.sh" "${DB_EXP_USER}" "${v_file}"
    rm -f "${v_file}"
  fi
fi

v_thisdir="${v_thisdir_bkp}" # REMOVE_IF_ZIP
sh "${v_thisdir}/dictionaryGet.sh" "${DB_EXP_USER}"

if ${DB_EXP_GEN_DUMP}
then
  sh "${v_thisdir}/dumpCreate.sh" "${DB_EXP_USER}" "tables_${v_pattern}.dmp" "${v_drop_dump_user}"
  set +e
  zip -m "${v_zip}" "tables_${v_pattern}.dmp" "tables_${v_pattern}.log"
  v_ret=$?
  set -eo pipefail
  if [ $v_ret -ne 0 ]
  then
    echoError "Script failed to zip tables_${v_pattern}.dmp in ${v_zip}". 
    v_file_user=$(stat -c '%U' tables_${v_pattern}.dmp)
    echoError "1 - Try to rerun as '${v_file_user}' user." 
    echoError "2 - Check file 'tables_${v_pattern}.dmp' permissions, make it readeable and run:". 
    echoError "$ zip ${v_zip} tables_${v_pattern}.dmp"
    exit $v_ret
  fi
fi

echo "Script Finished."

exit 0