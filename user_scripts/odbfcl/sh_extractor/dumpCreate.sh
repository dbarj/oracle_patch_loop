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

v_output="$1"

[ -z "$v_output" ] && exitError "First parameter is the target file and cannot be null."
[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -z "$ORACLE_SID" ] && exitError "\$ORACLE_SID is unset."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

v_output_fdr="$(cd "$(dirname "${v_output}")"; pwd)"
v_output_file="$(basename "${v_output}")"

v_output_full="${v_output_fdr}/${v_output_file}"

v_dump_user='hash'
v_dump_pass='HhAaSsHh..135'
v_dump_dir_name='expdir_hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

v_output_file_noext="${v_output_file%.*}"

v_output_file_cnt=`awk -F" " '{print NF-1}' <<< "${v_output_file_noext}"`
[ ${v_output_file_cnt} -ne 0 ] && exitError "File \"${v_output}\" must not have any spaces."

echo "Check if common user. Please wait.." 
v_common_user=$($ORACLE_HOME/bin/sqlplus -L -S "/ as sysdba" @get_user_prefix.sql)

[ -n "${v_common_user}" ] && v_dump_user="${v_common_user}${v_dump_user}"

echo "Generating table export. Please wait.." 

cd "${v_thisdir}"/../
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@tables_recreate.sql "${v_dump_user}" "${v_dump_pass}"
EOF

cd ..
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@externalDir.sql "${v_output_fdr}" "${v_dump_user}" "${v_dump_dir_name}"
EOF

cd odbfcl/extract/
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@hashGet.sql "${v_dump_user}"
EOF

$ORACLE_HOME/bin/expdp \
userid="${v_dump_user}/${v_dump_pass}" \
directory=${v_dump_dir_name} \
compression=all \
dumpfile="${v_output_file}" \
logfile="${v_output_file_noext}.log" \
content=data_only \
schemas="${v_dump_user}"

cd ../extract/sh_extractor/
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@cleanUser.sql "${v_dump_user}" "${v_dump_dir_name}"
EOF

exit 0
###