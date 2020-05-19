# SWEAGLE Integration to ANSIBLE

DESCRIPTION

This folder provides examples of script to integrate ANSIBLE with SWEAGLE

Use case are multiples:
- SWEAGLE as configuration control tower
    - use SWEAGLE as a control tower for any configuration deployed with ansible. SWEAGLE will validate a configuration before deploying it
    - For this use case, look at `/roles` folder and examples below

- SWEAGLE as vault for Ansible secrets
  - For this use case, look at `/plugins` folder

- ANSIBLE Facts as source of hosts information
  - push ANSIBLE Facts into SWEAGLE to run multiple validation rules on them or reuse them for cross validation with other configurations
  - discover & retrieve hosts configuration regularly to allow SWEAGLE to control configuration consistency, for example checking the patch level is correct or a package is present before deploying a new release requiring it.
  - For this use case, look at playbook file `uploadFacts.yml`, that relies on SWEAGLE `/roles` provided here also

The ansible roles provided here works both with API or CLI (if commands exists) depending on value of parameter "use_cli" available in ./group_vars/all.yml


# PRE-REQUISITES

ANSIBLE v2.5 is required for these scripts to work to allow support of loops


# CONTENT & EXAMPLES

Each SWEAGLE API/CLI command is available under a specific `/roles/sweagle` folder

Examples of playbooks to use them are available here:
- `all.yml` : launch all roles in sequence
- `info.yml` : launch only the info role that is used to check connection to your tenant
- `uploadFacts.yml` : upload ansible facts from current host to sweagle `ansible_facts` node
