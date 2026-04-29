variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group to deploy into."
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique storage account name (3-24 lowercase alphanumeric, no hyphens)."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters with no hyphens."
  }
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Key Vault that holds the customer-managed key."
}

variable "cmk_key_name" {
  type        = string
  description = "Name of the Key Vault key to use for customer-managed encryption."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Resource ID of the subnet for private endpoint placement. Must have private endpoint network policies disabled."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags. Must include: env, owner, cost-center."

  validation {
    condition = alltrue([
      contains(keys(var.tags), "env"),
      contains(keys(var.tags), "owner"),
      contains(keys(var.tags), "cost-center"),
    ])
    error_message = "Tags map must include all mandatory keys: env, owner, cost-center."
  }
}
