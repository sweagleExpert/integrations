storage mysql {
  address = \"sweagle-mysql:3306\"
  username = \"$VAULT_DB_USER\"
  password = \"$VAULT_DB_PASSWORD\"
  database = \"$VAULT_DB\"
  scheme = \"http\"
}
listener tcp {
  address = \"0.0.0.0:8200\"
  tls_disable = 1
}
disable_mlock = true
