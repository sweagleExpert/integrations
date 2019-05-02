#!/usr/bin/env bash
source $(dirname "$0")/ldap.env

ldapadd -D $ldapUser -c -f userCreate.ldif -h $ldapHost -p $ldapPort -x -w $ldapPassword
