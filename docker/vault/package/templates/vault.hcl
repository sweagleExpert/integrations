storage mysql {
  address = \"$VAULT_DB_HOST:$VAULT_DB_PORT\"
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
