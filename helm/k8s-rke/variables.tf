variable "azure_subscription_id" {
  default     = "..."
  description = "Azure Subscription ID"
}
variable "azure_tenant_id" {
  default     = "..."
  description = "Azure Tenant ID"
}
variable "azure_region" {
  default     = "francecentral"
  description = "Azure Region for deployment"
}
variable "azure_instance_type" {
  default     = "Standard_DS2_v2"
  description = "Azure Instance Type"
}
variable "azure_storage_type" {
  default     = "Standard_LRS"
  description = "Azure Storage Type"
}
variable "azure_admin_password" {
  default     = "..."
  description = "Password for the Azure User"
}
variable "azure_ssh_key_local_path" {
  default     = "~/.ssh/id_rsa"
  description = "Local path of the Azure Key Pair Name"
}