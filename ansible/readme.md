# SWEAGLE Integration to ANSIBLE

## DESCRIPTION

This folder provides examples of script to integrate ANSIBLE with SWEAGLE

Use case are multiples:
1. SWEAGLE as configuration control tower
    - use SWEAGLE as a control tower for any configuration deployed with ansible. SWEAGLE will validate a configuration before deploying it
    - for this use case, look at `/roles` folder and examples below

2. SWEAGLE as storage for Ansible vars
  - remove the pain from manually managing Ansible vars files
  - have more secure storage with SWEAGLE fine-grained RBAC
  - benefit from validation rules
  - benefit from automatic tokens calculation based on target deployed environment
  - for this use case, look at `/plugins` folder

3. SWEAGLE as vault for Ansible secrets
  - this is similar to use case 2 above with use of specific SWEAGLE ConfigDataSet called `vault`
  - for this use case, look at `/plugins` folder

4. ANSIBLE Facts as source of SWEAGLE hosts information
  - push ANSIBLE Facts into SWEAGLE to run multiple validation rules on them or reuse them for cross validation with other configurations
  - discover & retrieve hosts configuration regularly to allow SWEAGLE to control configuration consistency, for example checking the patch level is correct or a package is present before deploying a new release requiring it.
  - for this use case, look at playbook file `uploadFacts.yml`, that relies on SWEAGLE `/roles` provided here also

The ansible roles provided here works both with API or CLI (if commands exists) depending on value of parameter "use_cli" available in ./group_vars/all.yml


## PRE-REQUISITES

ANSIBLE v2.5 is required for these scripts to work to allow support of loops


## INSTALLATION

- For all use cases, you can benefit from SWEAGLE most used APIs to upload, validate, snapshot or export your configuration data by using roles provided in `/roles` folder

- If you plan to use CLI and ask ansible to install it using `installCLI` role, don't forget to put SWEAGLE CLI binaries under `/roles/sweagle/installCLI/files`

- For uses cases 2 & 3, you can install SWEAGLE specific plugins directly next to your plays in a `/lookup_plugins` folder or by putting in ansible default plugins folders, like `~/.ansible/plugins/lookup:/usr/share/ansible/plugins/lookup`

- More details on custom plugins installation are available here:
https://docs.ansible.com/ansible/latest/plugins/lookup.html#enabling-lookup-plugins


## CONTENT & EXAMPLES

Each SWEAGLE API/CLI command is available under a specific `/roles/sweagle` folder

Examples of playbooks to use them are available here:
- `all.yml` : launch all roles in sequence
- `info.yml` : launch only the info role that is used to check connection to your tenant
- `uploadFacts.yml` : upload ansible facts from current host to sweagle `ansible_facts` node
