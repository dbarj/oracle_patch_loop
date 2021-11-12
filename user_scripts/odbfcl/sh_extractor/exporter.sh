#!/bin/bash
# Script to get all bugs fixed on OPatch
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

v_pattern="$1"

[ -z "$v_pattern" -o "$#" -ne 1 ] && exitError "Usage: $0 <pattern>

First parameter is the file name pattern and cannot be null.

The pattern is composed by 3 parts, divided by \"_\":
1st - Version, in the X.X.X.X format.
2nd - Type. Can be any string.
3rd - ID. Must be a number.

Eg: $0 19.0.0.0_RU-L_14

The output is a zip file.
"

v_pattern_cnt=`awk -F"_" '{print NF-1}' <<< "${v_pattern}"`
[ ${v_pattern_cnt} -ne 2 ] && exitError "Pattern \"${v_output}\" must have 2 \"_\" on it. Eg: 19.0.0.0_RU-L_14"

v_pattern_cnt=`awk -F" " '{print NF-1}' <<< "${v_pattern}"`
[ ${v_pattern_cnt} -ne 0 ] && exitError "Pattern \"${v_output}\" must not have any spaces. Eg: 19.0.0.0_RU-L_14"

v_patch_version=`cut -d '_' -f 1 <<< "${v_pattern}"`
v_patch_type=`cut -d '_' -f 2 <<< "${v_pattern}"`
v_patch_id=`cut -d '_' -f 3 <<< "${v_pattern}"`

v_pattern_cnt=`awk -F"." '{print NF-1}' <<< "${v_patch_version}"`
[ ${v_pattern_cnt} -ne 3 ] && exitError "Version \"${v_patch_version}\" must be in \"X.X.X.X\" format. Eg: 19.0.0.0_RU-L_14"

re='^[0-9]+$'
if ! [[ $v_patch_id =~ $re ]] ; then
   exitError "\"$v_patch_id\" must be a number. Eg: 19.0.0.0_RU-L_14"
fi

v_zip=${v_pattern}.zip

v_file=bugs_${v_pattern}.txt
sh bugsGet.sh ${v_file}
zip -m ${v_zip} ${v_file}

v_file=sha256sum_${v_pattern}.chk
sh fileGet.sh ${v_file}
zip -m ${v_zip} ${v_file}

v_file=txtcol_${v_pattern}.tar.gz
sh fileCollect.sh ${v_file}
zip -m ${v_zip} ${v_file}

v_file=symbols_${v_pattern}.csv
sh symbolGet.sh ${v_file}
zip -m ${v_zip} ${v_file}

sh dumpCreate.sh ${v_pattern}.dmp
mv ${v_pattern}.dmp tables_${v_pattern}.dmp
mv ${v_pattern}.log tables_${v_pattern}.log
zip -m ${v_pattern}.zip tables_${v_pattern}.dmp
zip -m ${v_pattern}.zip tables_${v_pattern}.log

exit 0