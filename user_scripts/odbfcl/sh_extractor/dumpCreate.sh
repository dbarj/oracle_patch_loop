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

v_user='c##hash'
v_pass='hash'

v_thisdir="$(cd "$(dirname "$0")"; pwd)"

v_output_file_noext="${v_output_file%.*}"

v_output_file_cnt=`awk -F"_" '{print NF-1}' <<< "${v_output_file_noext}"`
[ ${v_output_file_cnt} -ne 2 ] && exitError "File \"${v_output}\" must have 2 \"_\" on the name."

v_output_file_cnt=`awk -F" " '{print NF-1}' <<< "${v_output_file_noext}"`
[ ${v_output_file_cnt} -ne 0 ] && exitError "File \"${v_output}\" must not have any spaces."

v_patch_version=`cut -d '_' -f 1 <<< "${v_output_file_noext}"`
v_patch_type=`cut -d '_' -f 2 <<< "${v_output_file_noext}"`
v_patch_id=`cut -d '_' -f 3 <<< "${v_output_file_noext}"`

v_output_file_cnt=`awk -F"." '{print NF-1}' <<< "${v_patch_version}"`
[ ${v_output_file_cnt} -ne 3 ] && exitError "Version \"${v_patch_version}\" must be in \"X.X.X.X\" format."

re='^[0-9]+$'
if ! [[ $v_patch_id =~ $re ]] ; then
   exitError "\"$v_patch_id\" must be a number."
fi

echo "Generating tables export. Please wait.." 

cd "${v_thisdir}"/../
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@tables_recreate.sql
EOF

cd ..
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@externalDir.sql ${v_output_fdr}
EOF

cd odbfcl/extract/
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@hashGet.sql ${v_patch_id} ${v_patch_type} ${v_patch_version}
EOF

$ORACLE_HOME/bin/expdp \
userid="${v_user}/${v_pass}" \
directory=expdir \
compression=all \
dumpfile="${v_output_file}" \
logfile="${v_output_file_noext}.log" \
content=data_only \
schemas="${v_user}"

cd ../extract/sh_extractor/
$ORACLE_HOME/bin/sqlplus "/ as sysdba" <<EOF
@cleanUser.sql
EOF

exit 0
###