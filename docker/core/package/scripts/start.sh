#!/bin/bash
if [[ -z ${VAULT_ROOT_TOKEN} ]]; then
  echo "### No VAULT_ROOT_TOKEN defined as ENV variable, checking file"
  i=0
  while [[ ! (-f /vault/.root-token || -f /vault/unseal.txt) ]]; do
    echo "### VAULT NOT YET INITIALISED -- WAITING"
    sleep 10
    ((i++))
    if [[ $i -gt 12 ]]; then
      break
    fi
  done

  # New mode using .root-token
  if [[ -f /vault/.root-token ]]; then
    echo "### Taking root token value from root file"
    token=$(cat /vault/.root-token)

  # Compatibility with old mode using unseal.txt
  elif [[ -f /vault/unseal.txt ]]; then
    echo "### Taking root token value from unseal file"
    token=$(cat /vault/unseal.txt|grep "Initial"|sed -r 's/Initial Root Token: (.+)/\1/')
  fi
else
  echo "### Taking root token value from env"
  token="${VAULT_ROOT_TOKEN}"
fi

if [[ -z ${token} ]]; then
  echo "### NO VAULT CONFIG FOUND, STARTING SWEAGLE WITHOUT IT"
else
  echo "### CHECKING VAULT CONFIG IN SWEAGLE"
  if [[ $(cat /opt/SWEAGLE/bin/core/application.yml|grep "token: $token") ]]; then
    echo "### Token found"
  else
    echo "### Token NOT found, adding it"
    sed -E -i "s/token: .+/token: $token/" /opt/SWEAGLE/bin/core/application.yml
  fi
  echo "### VAULT CONFIG DONE SUCCESSFULLY"
fi

/opt/SWEAGLE/scripts/startCORE.sh
