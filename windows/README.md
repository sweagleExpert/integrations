# WINDOWS Integrations

This folder contains scripts to call SWEAGLE APIs through powershell.

The strategy adopted is to use library present here in your own powershell scripts:

- `sweagle-lib.ps1` contains all common APIs used to upload/validate/ValidationStatus/snapshot/export config data

- `test-sweagle-lib.ps1` script is an example on how to use `sweagle-lib`

Please note that `sweagle-lib` relies on `db.json` to provide  parameters and token to connect to your Sweagle tenant. This file is the same as the one used to connect with Sweagle CLI (Command Line Interface) program.


During transition period, you will also find in `/archive` folder former shell scripts that contains direct calls to APIs for specific use cases.
