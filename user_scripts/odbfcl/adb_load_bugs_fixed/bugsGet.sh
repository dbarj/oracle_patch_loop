#!/bin/bash
# Script to get all bugs fixed on OPatch
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

v_out_file_param="$1"

[ -z "${v_out_file_param}" ] && exitError "First parameter is the target file and cannot be null."
[ -f "${v_out_file_param}" ] && exitError "File \"${v_out_file_param}\" already exists. Remove it before rerunning."

[ -z "$ORACLE_HOME" ] && exitError "\$ORACLE_HOME is unset."

echo "Generating bugs list. Please wait.." 

# Check if opatch command works
v_opatch_out=$("$ORACLE_HOME"/OPatch/opatch lsinv -bugs_fixed 2>&1) && v_ret=$? || v_ret=$?
if [ ${v_ret} -ne 0 ]
then
  echoError "Unable to run opatch. Error was:"
  echoError "${v_opatch_out}"
  echoError "Skipping opatch collection."
  exit ${v_ret}
fi

# When opatch runs again and too fast, it will fail as the lsinventory file name will have the exact same name (even the seconds part of it).
# Example:

# Inventory load failed... OPatch cannot load inventory for the given Oracle Home.
# LsInventorySession failed: LsInventory cannot create the log directory /u01/app/oracle/product/database/dbhome_1/cfgtoollogs/opatch/lsinv/lsinventory2024-03-20_13-56-38PM.txt

# "$ORACLE_HOME"/OPatch/opatch lsinv -bugs_fixed |
echo "${v_opatch_out}" |
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
sed -r 's/[[:space:]]+/ /g' |
# Remove date columns
awk '{$3=$4=$5=$6=$7=$8=""; print $0}' |
# Remove double spaces again after column removal
sed -r 's/[[:space:]]+/ /g' |
# Replace first space per tab
sed 's/ /'$'\t''/' |
# Replace first space per tab (that was the second)
sed 's/ /'$'\t''/' > "${v_out_file_param}"

exit 0