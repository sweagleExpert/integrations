# WINDOWS Integrations

This folder contains scripts to call SWEAGLE APIs through powershell.

The strategy adopted is to use library present here in your own powershell scripts:

- `sweagle-lib.ps1` contains all common APIs used to upload/validate/ValidationStatus/snapshot/export config data

Example of usage is present in `test-sweagle-lib.ps1` script.

During transition period, you will also find in `/archive` folder former shell scripts that contains direct calls to APIs for specific use cases.
