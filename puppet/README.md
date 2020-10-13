## SWEAGLE INTEGRATION TO PUPPET


# DESCRIPTION

This folder provides examples of configuration to use SWEAGLE into Puppet.
Several use cases are possible:

- Use SWEAGLE as HIERA backend, SWEAGLE will replace any configuration file, retrieving the harness of managing these files, storing and backuping them, and ensuring sensitive data are protected. Configuration data will be provided on the fly to Puppet directly through HTTP REST call to SWEAGLE APIs. As this integrates completely beyond Puppet Hiera framework, there is no impact on any deployment code, it will be transparent to existing deployment modules.

- Use SWEAGLE as approval gate before you make any deployment, use validation rules to check that configuration you plan to deploy follows all your format, templates and other compliancy rules you defined.

- SWEAGLE can also fill tokens and configuration files to deploy in the expected format for the consumer of these files (for example: applications configurations)


# PRE-REQUISITES

- Puppet server and agents must be installed
Please check [**README_PREREQUISITES.md**](./README_PREREQUISITES.md) if you want to install a sample Puppet for test purpose


# INSTALLATION SWEAGLE AS HIERA BACKEND

For SWEAGLE as HIERA backend use case:
- Update all backend functions under `./lib/puppet/functions/sweagle_*.rb` with your default tenant and token values. You can also put default ConfigDataSet (cds) and node, but they will be overidden by values from `hiera.yaml` if provided

- Update `hiera.yaml` with your cds, node, tenant and token values. Any value here will override values in your backend function, like `sweagle_data_hash.rb`

- Copy folder `/lib` in
    - `/etc/puppetlabs/code/environments/<YOUR_ENVIRONMENT>`
    - for example `/etc/puppetlabs/code/environments/production`

- Copy file `hiera.yml` in
    - `/etc/puppetlabs/puppet` to define a global data provider
    - `/etc/puppetlabs/code/environments/<YOUR_ENVIRONMENT>` to define an environment specific data provider
    - `/etc/puppetlabs/code/environments/<YOUR_ENVIRONMENT>/modules/<YOUR_MODULE>` to define a module specific data provider


# INSTALLATION SWEAGLE AS APPROVAL GATE

For SWEAGLE as approval gate and other config checker/provisioner use cases:
- Put latest releases of SWEAGLE CLI in /modules/sweagle_install_cli/files/

- Update /modules/sweagle_install_cli/files/db.json with your tenant settings

- Update ./manifests/site.pp based on configuration you want to upload or validate. You can now use any SWEAGLE CLI features within puppet class

- Copy folders /manifests, /modules in `/etc/puppetlabs/code/environments/<YOUR_ENVIRONMENT>`

Current ./manifests/site.pp gives examples on how to:
- install SWEAGLE CLI
- retrieve Puppet facts and store them in SWEAGLE for future validations,
- upload any configuration data file in SWEAGLE
- run a validation towards a configuration and stop deployment if it fails


# TEST IT WORKS

For SWEAGLE as HIERA backend use case, run:
`puppet lookup <your_key> --explain`
where <your_key> is a SWEAGLE key

For SWEAGLE as approval gate, connect to any server agent in the environment you selected and run:
`puppet agent --test`


# LIMITATIONS

- current SWEAGLE CLI installation module has only been tested on linux. Even if code for windows and macOS are present, some adaptations may be needed in /modules/sweagle_install_cli/manifests/init.pp
