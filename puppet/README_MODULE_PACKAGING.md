## SWEAGLE INTEGRATION TO PUPPET MODUEL PACKAGING

If you want to package the SWEAGLE modules provided here to facilitate installation, you can do it using instructions below.


# BUILD YOUR PACKAGE

- Go to /modules folder

- Create a metadata.json file containing
{
  "name": "sweagle-sweagle_install_cli",
  "version": "1.0.0",
  "author": "Dimitris Finas",
  "summary": "Module to install SWEAGLE CLI",
  "source": "https://github.com/sweagleExpert/integrations/tree/master/puppet",
  "project_page": "https://github.com/sweagleExpert/integrations/tree/master/puppet",
  "issues_url": "https://github.com/sweagleExpert/integrations/ssues",
  "dependencies": [
  ]
}

- Package the module
`tar -zcvf sweagle-sweagle_install_cli-1.0.0.tar.gz .`


# INSTALLATION

- Copy the module to tar file into the /tmp folder of the server where you want to install it
- Run
`puppet module install sweagle-sweagle_install_cli-1.0.0.tar.gz --ignore-dependencies`


# UNINSTALL

`puppet module uninstall sweagle_install_cli --ignore-changes`