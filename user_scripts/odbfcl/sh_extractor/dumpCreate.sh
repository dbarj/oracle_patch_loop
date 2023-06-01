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

v_dump_user="$1"
v_output="$2"

[ -z "$v_output" ] && exitError "First parameter is the target file and cannot be null."
[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

v_output_fdr="$(cd "$(dirname "${v_output}")"; pwd)"
v_output_file="$(basename "${v_output}")"

v_output_full="${v_output_fdr}/${v_output_file}"

v_dump_pass='HhAaSsHh..135'
v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

v_output_file_noext="${v_output_file%.*}"

v_output_file_cnt=`awk -F" " '{print NF-1}' <<< "${v_output_file_noext}"`
[ ${v_output_file_cnt} -ne 0 ] && exitError "File \"${v_output}\" must not have any spaces."

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../../
$ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" <<EOF
@externalDir.sql "${v_output_fdr}" "${v_dump_user}" "${v_dump_dir_name}"
EOF

# Get DB Version
v_version=$($ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" @${v_thisdir}/get_db_version.sql)
[ -z "${v_version}" ] && v_version=0

if [ $v_version -lt 12 ]
then
  v_compress_alg=''
else
  v_compress_alg='compression_algorithm=high'
fi

$ORACLE_HOME/bin/expdp \
userid="${v_dump_user}/${v_dump_pass}" \
directory=${v_dump_dir_name} \
compression=all "${v_compress_alg}" \
dumpfile="${v_output_file}" \
logfile="${v_output_file_noext}.log" \
content=data_only \
schemas="${v_dump_user}"

cd odbfcl/sh_extractor/
$ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" <<EOF
set verify off
@cleanUser.sql "${v_dump_user}" "${v_dump_dir_name}"
EOF

exit 0
###