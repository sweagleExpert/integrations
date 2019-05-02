#!/usr/bin/env bash
source $(dirname "$0")/ldap.env

sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f enableMemberOf-1.ldif
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f enableMemberOf-2.ldif
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f enableMemberOf-3.ldif
