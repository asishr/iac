variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "eastus"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID for Key Vault."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
