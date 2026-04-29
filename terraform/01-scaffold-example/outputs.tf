output "storage_account_id" {
  description = "Resource ID of the storage account."
  value       = azurerm_storage_account.diag.id
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.diag.name
}

output "private_endpoint_ip" {
  description = "Private IP address assigned to the storage blob private endpoint."
  value       = azurerm_private_endpoint.storage_blob.private_service_connection[0].private_ip_address
}

# Note: primary_access_key is intentionally NOT exported.
# Access should be granted via RBAC (Storage Blob Data Contributor) and Managed Identity.
# Ask Copilot: "What role should I assign to grant read access to blob data without using access keys?"
