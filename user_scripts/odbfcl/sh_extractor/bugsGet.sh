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

v_output="$1"

[ -z "$v_output" ] && exitError "First parameter is the target file and cannot be null."
[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."
[ -f "${v_output}" ] && exitError "File \"${v_output}\" already exists. Remove it before rerunning."

echo "Generating bugs list. Please wait.." 

"${ORACLE_HOME}"/OPatch/opatch lsinv -bugs_fixed |
# Remove lines before this entry (inclusive)
sed '1,/^List of Bugs fixed by Installed Patches/d' |
# Remove lines before this entry (inclusive)
sed '1,/^---/d' |
# Remove lines after this entry (inclusive)
sed '/^---/Q' |
# Remove empty lines
sed '/^$/d' |
# Remove breaks from lines not starting with number
sed ':a $!{N; ba}; s/\n\+/\n/g; s/\n\([^0-9]\)/\1/g' |
# Remove double spaces
sed -E 's/[[:space:]]+/ /g' |
# Remove date columns
awk '{$3=$4=$5=$6=$7=$8=""; print $0}' |
# Remove double spaces again after column removal
sed -E 's/[[:space:]]+/ /g' |
# Replace first space per tab
sed 's/ /'$'\t''/' |
# Replace first space per tab (that was the second)
sed 's/ /'$'\t''/' > "${v_output}"

exit 0