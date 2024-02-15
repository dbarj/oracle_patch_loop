#!/bin/bash
# Script to collect dictionary tables
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

v_dump_user_name="$1"
v_output="$2"

[ -z "$v_output" ] && exitError "First parameter is the target file and cannot be null."
[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

v_output_fdr="$(cd "$(dirname "${v_output}")"; pwd)"
v_output_file="$(basename "${v_output}")"
v_output_file_noext="${v_output_file%.*}"

v_output_full="${v_output_fdr}/${v_output_file}"
v_output_error="${v_output_fdr}/${v_output_file_noext}.err"

# If DB_EXP_USER_PASS is exported, use it as the password.
[ -n "$DB_EXP_USER_PASS" ] && v_dump_user_pass="$DB_EXP_USER_PASS" || v_dump_user_pass='HhAaSsHh..135'

v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"
cd "${v_thisdir}"

v_output_file_cnt=`awk -F" " '{print NF-1}' <<< "${v_output_file_noext}"`
[ ${v_output_file_cnt} -ne 0 ] && exitError "File \"${v_output}\" must not have any spaces."

[ -z "${v_sysdba_connect}" ] && v_sysdba_connect='/ as sysdba'

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../../ # REMOVE_IF_ZIP
$ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" <<EOF
@externalDir.sql "${v_output_fdr}" "${v_dump_user_name}" "${v_dump_dir_name}"
EOF

# Get DB Version
v_version=$($ORACLE_HOME/bin/sqlplus -L -S "${v_sysdba_connect}" @${v_thisdir}/get_db_version.sql)
[ -z "${v_version}" ] && v_version=0

if [ $v_version -lt 12 ]
then
  v_compress_alg=''
else
  v_compress_alg='compression_algorithm=high'
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
compression=all "${v_compress_alg}" \
dumpfile="${v_output_file}" \
logfile="${v_output_file_noext}.log" \
content=data_only \
schemas="${v_dump_user_name}" 2>&1 >&3 | tee "${v_output_error}"
v_ret=$?
set -eo pipefail

if [ ${v_ret} -ne 0 ]
then
  if grep -q 'ORA-39070: Unable to open the log file' "${v_output_error}"
  then
    v_ora_user=$(stat -c '%U' $ORACLE_HOME/bin/expdp)
    exitError "Error, check if the Oracle Database ('${v_ora_user}' user) has access to this directory: ${v_output_fdr}"
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