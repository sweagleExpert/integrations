output "k8s-controlplane-public-ip" {
  value = azurerm_public_ip.k8s-public-ip-controlplane.ip_address
}