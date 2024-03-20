#!/bin/bash
# Script to collect dictionary tables
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

v_dump_user_name="$1"
v_out_file_param="$2"

[ -z "${v_out_file_param}" ] && exitError "First parameter is the target file and cannot be null."
[ -f "${v_out_file_param}" ] && exitError "File \"${v_out_file_param}\" already exists. Remove it before rerunning."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."

v_out_file_fdr="$(cd "$(dirname "${v_out_file_param}")"; pwd)"
v_out_file_name="$(basename "${v_out_file_param}")"
v_out_file_name_noext="${v_out_file_name%.*}"

v_out_file_full="${v_out_file_fdr}/${v_out_file_name}"
v_err_file_full="${v_out_file_fdr}/${v_out_file_name_noext}.err"

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_PASS" ] && v_dump_user_pass="$DB_EXP_USER_PASS" || v_dump_user_pass='HhAaSsHh..135'

v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

v_output_file_cnt=`awk -F" " '{print NF-1}' <<< "${v_out_file_name_noext}"`
[ ${v_output_file_cnt} -ne 0 ] && exitError "File \"${v_out_file_param}\" must not have any spaces."

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../../ # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
@externalDir.sql "${v_out_file_fdr}" "${v_dump_user_name}" "${v_dump_dir_name}"
EOF

# Get DB Version
v_version=$($ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" @${v_thisdir}/get_db_version.sql)
[ -z "${v_version}" ] && v_version=0

if [ $v_version -eq 10 ]
then
  v_compress_alg=''
elif [ $v_version -eq 11 ]
then
  v_compress_alg='compression=all'
else
  v_compress_alg='compression=all compression_algorithm=high'
fi

if [ $v_version -gt 19 ]
then
  v_version_param="version=19"
else
  v_version_param=''
fi

# This makes file descriptor 3 be a copy of the current stdout (i.e. the screen),
# then sets up the pipe and runs expdp 2>&1 >&3. This sends the stderr of expdp
# to the same place as the current stdout, which is the pipe, then sends the stdout
# to fd 3, the original output. The pipe feeds the original stderr of expdp to tee,
# which saves it in a file and sends it to the screen.
exec 3>&1

set +e
$ORACLE_HOME/bin/expdp \
userid="${v_dump_user_name}/${v_dump_user_pass}" \
directory=${v_dump_dir_name} \
"${v_compress_alg}" \
dumpfile="${v_out_file_name}" \
logfile="${v_out_file_name_noext}.log" \
content=data_only "${v_version_param}" \
schemas="${v_dump_user_name}" 2>&1 >&3 | tee "${v_err_file_full}"
v_ret=$?
set -eo pipefail

if [ ${v_ret} -ne 0 ]
then
  if grep -q 'ORA-39070: Unable to open the log file' "${v_err_file_full}"
  then
    v_ora_user=$(stat -c '%U' $ORACLE_HOME/bin/expdp)
    exitError "Error, check if the Oracle Database ('${v_ora_user}' user) has access to this directory: ${v_out_file_fdr}"
  else
    exitError 'Error when generating dump file.'
  fi
fi

cd odbfcl/sh_extractor/ # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
set verify off
@cleanUser.sql "${v_dump_user_name}" "${v_dump_dir_name}"
EOF

exit 0
###