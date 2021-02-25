# LINUX Integrations

This folder contains scripts to call SWEAGLE APIs through shell script.

The strategy adopted is to import one the 2 libraries present here in your shell scripts:

- sweagle.lib for all common APIs used to upload/validate/snapshot/export config data, but also to realize operations on datamodel like creating Config Data Set (CDS), Config Data Item (CDI) includes, changesets ...

- sweagle-admin.lib for all admin APIs used to create or update users, roles, parsers, node or config data item types, ...

Example of usage is present in examples folder.

During transition period, you will also find in this folder former shell scripts that contains direct calls to APIs for specific use cases.

Please, note that SWEAGLE provides also a Command Line Interface tool (CLI) that provides easy access to all common APIs and more.
It is available for downloading for MacOS, Linux and Windows, directly from your instance:
- once connected, just go to "Help" button and select the version you want to download.
