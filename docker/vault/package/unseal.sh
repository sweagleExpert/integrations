#!/bin/bash
echo "###############################################################"
echo "### BEGIN UNSEAL SCRIPT V5"
echo "###############################################################"

# Sleep few seconds to let time for vault to start
wait-for-it.sh localhost:8200
vault init -check -address=http://127.0.0.1:8200
rc=$?
# Check return code
## return code of 0 means init already done, 1 - error, 2 - init not done
## cf. vault init --help
if [ "${rc}" -eq "0" ]; then
  echo "### VAULT ALREADY INITIALIZED"

elif [ "${rc}" -eq "1" ]; then
  echo "### FATAL ### Error initializing Vault, please restart"
  echo "#  1- Check if MySQL is active"
  echo "#  2- Check if you target correct DB for this vault"
  echo "#  3- Recreate vault DB if no sensitive data"
  # Restart the container
  reboot
  exit ${rc}

elif [ "${rc}" -eq "2" ]; then
  echo "### INITIALIZING VAULT"
  vault init > /vault/unseal.txt
  if [[ -n "${DEBUG_VAULT}" ]]; then
    cat /vault/unseal.txt
  fi
  echo "### Vault init done"
fi

# Adapting old vault config format to new format
if [[ -f /vault/unseal.txt ]]; then
  echo "### Creating root token file"
  token=$(cat /vault/unseal.txt|grep "Initial"|sed -r 's/Initial Root Token: (.+)/\1/')
  echo "$token" > /vault/.root-token

  echo "### Creating token files"
  i=1
  while read line; do
    if [[ $(echo "${line}"|grep "Unseal Key") ]]; then
      token=$(echo $line|sed -r 's/Unseal Key .+: (.+)$/\1/g')
      echo "$token" > /vault/.token-$i
      ((i++))
    fi
  done < /vault/unseal.txt

  rm /vault/unseal.txt
  echo "### VAULT INIT PROCESS FINISHED SUCCESSFULLY"
fi

echo "### CHECK VAULT SEAL STATUS"
sealStatus=$(vault status|grep "Sealed"|sed -r 's/Sealed: (.+)/\1/')

if [ "${sealStatus}" = "true" ]; then
  echo "### UNSEALING VAULT"
  for i in 1 2 3; do
    if [ -f /vault/.token-$i ];  then
      token=$(cat /vault/.token-$i)
    else
      echo "### FATAL ### No token found, please restart"
      # Restart the container
      reboot
      exit 1
    fi
    if [[ -n "${DEBUG_VAULT}" ]]; then
      echo "Unsealing with token $token"
    fi
    vault unseal $token
  done
fi
echo "### VAULT UNSEALED"

echo "###############################################################"
echo "### END UNSEAL SCRIPT"
echo "###############################################################"
