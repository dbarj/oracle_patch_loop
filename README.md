# Oracle Patch Loop Applier #

Oracle Patch Loop Applier is an ansible playbook that will loop over all existent configured Oracle Patches, running your scripts on the database and collecting information.
You can use it to extract some specific oracle configuration (from both OS or DB) for all oracle versions/patches and later compare them for changes.
The result will be exported using expdp and moved to a folder repository in your computer.

## How it works ##

Using VirtualBox VM snapshots, the playbook will loop over a list of the available patches doing the following steps:
- Restore VM to base snapshot.
- Apply Oracle Patch.
- Collect the information you want.
- Load the information into an Oracle Table and export it using expdp.

## Available version ##

The playbook was tested and is currently working for all PSUs, OJVM PSUs, Bundle Patches, RUs or RURs for the following versions:

- 11.2.0.4
- 12.1.0.1
- 12.1.0.2
- 12.2.0.1
- 18
- 19

_P.S: For details of versions and patches that are processed, check list_versions.yml and list_patches.yml files._

## Execution Steps ##

1. Clone the repository to your compute:

``` shell
$ git clone https://github.com/dbarj/oracle_patch_loop.git
$ cd oracle_patch_loop
```

2. Edit config_vars.yml with your current environment configuration. Each variable use is detailed on the file.

3. Change remote_user with the SSH variable value in ansible.cfg, if not using "oracle" account.

4. Execute the playbook:

``` shell
$ ansible-playbook main.yml
```

Optionally, you can declare the following command line variables to limit the code execution scope:

- **param_version** : Will limit the execution only for the given version:

``` shell
$ ansible-playbook main.yml --extra-vars "param_version=18.0.0.0"
```

- **param_type** : Will limit the execution only for the given patch type:

``` shell
$ ansible-playbook main.yml --extra-vars "param_version=11.2.0.4 param_type=BP"
$ ansible-playbook main.yml --extra-vars "param_version=12.2.0.1 param_type=RU"
```

- **param_patch** : Will limit the execution only for the given patch version:

``` shell
$ ansible-playbook main.yml --extra-vars "param_version=12.2.0.1 param_type=RU param_patch=190416"
```

- **param_patch_from** or **param_patch_to** : Will limit the execution range for the given patch version:

``` shell
$ ansible-playbook main.yml --extra-vars "param_version=12.2.0.1 param_type=RU param_patch_from=180116"
```

_P.S: Note that all the 5 parameters above are independent._

## Pre-requisites ##

* Passwordless SSH connection to VM user.
* Passwordless sudo to root for VM user.
* A shared folder between your machine and the VirtualBox VM must exists and properly configured in config_vars.yml.
* Base Image used for each release must already have latest OPatch version.
* VM must be configured to have the network interface auto-started as soon as snapshot is loaded.

## Versions ##
* v1.04 (2019-08-04) by Rodrigo Jorge
* v1.03 (2019-06-05) by Rodrigo Jorge
* v1.02 (2019-05-17) by Rodrigo Jorge
* v1.01 (2019-05-13) by Rodrigo Jorge