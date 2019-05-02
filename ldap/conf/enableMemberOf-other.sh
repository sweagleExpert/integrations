#!/usr/bin/env bash
source $(dirname "$0")/ldap.env

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f enableMemberOf-other.ldif
