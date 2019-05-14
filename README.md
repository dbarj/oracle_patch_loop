# Oracle Patch Loop Applier #

Oracle Patch Loop Applier is an ansible tool that will loop over all existent configured Oracle Patches and run your scripts for this database.
You can use it to collect some specific oracle configuration (In either OS or inside the DB) for all oracle versions/patches and later compare for changes.
The result will be exported using expdp and moved to a folder repository in your computer.

## How it works ##

Using VirtualBox VM snapshots, the tool will loop over a list of the available patches doing the following steps:
- Restore VM to base snapshot.
- Apply Oracle Patch.
- Collect the information you need.
- Load the information into an Oracle Table and export using expdp.

## Available version ##

The tool was tested and is working for all PSUs, OJVM PSUs, Bundle Patches, RUs or RURs for the following versions:

- 11.2.0.4
- 12.1.0.1
- 12.1.0.2
- 12.2.0.1
- 18.0.0.0
- 19.0.0.0

## Execution Steps ##

1. Clone the repository to your compute:

   $ git clone https://github.com/dbarj/oracle_patch_loop.git
   $ cd oracle_patch_loop

2. Edit config_vars.yml with your current environment configuration.

3. Change remote_user with the SSH variable value in ansible.cfg.

4. Execute the tool:

   $ ansible-playbook main.yml

   Optionnaly, you can declare the following variables to limit the code execution scope:

   - param_version : Will limit the execution only for the given version:
   $ ansible-playbook main.yml --flush-cache --extra-vars "param_version=18.0.0.0"

   - param_type : Will limit the execution only for the given patch type:
   $ ansible-playbook main.yml --flush-cache --extra-vars "param_version=11.2.0.4 param_type=BP"
   $ ansible-playbook main.yml --flush-cache --extra-vars "param_version=12.2.0.1 param_type=RU"

   - param_patch : Will limit the execution only for the given patch version:
   $ ansible-playbook main.yml --flush-cache --extra-vars "param_version=12.2.0.1 param_type=RU param_patch=190416"

   - param_patch_from or param_patch_to : Will limit the execution only for the given patch version:
   $ ansible-playbook main.yml --flush-cache --extra-vars "param_version=12.2.0.1 param_type=RU param_patch_from=180116"

## Notes ##


## Versions ##
* v1.01 (2019-05-13) by Rodrigo Jorge