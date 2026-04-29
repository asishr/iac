# DEMO EXERCISE 3 — Security Review
# ──────────────────────────────────
# This file contains deliberate security issues for the audience to find
# — with Copilot's help.
#
# Prompt to use in Copilot Chat:
#   "Review this Terraform file for security concerns and missing Azure best practices.
#    List findings as: Severity | Issue | Recommendation"
#
# Issues hidden in this file (presenter reference — 8 total):
#   1.  [HIGH]   Storage: public blob access enabled
#   2.  [HIGH]   Storage: HTTPS not enforced
#   3.  [HIGH]   Storage: minimum TLS not set (defaults to TLS 1.0)
#   4.  [MEDIUM] Storage: no soft delete configured
#   5.  [HIGH]   NSG: allow-all inbound rule (wildcard source + any destination port)
#   6.  [HIGH]   Key Vault: purge protection disabled
#   7.  [MEDIUM] Key Vault: no network ACLs (public access allowed)
#   8.  [HIGH]   Output: storage primary_access_key not marked sensitive
#
# Teaching point: Copilot is a fast first-pass reviewer.
# It does NOT replace Checkov, tfsec, or Azure Policy in your pipeline.
# ──────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ── Storage Account (contains issues 1-4) ────────────────────────

resource "azurerm_storage_account" "data" {
  name                     = "stdemoproddata001"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Issue 1: Public blob access is enabled — anonymous reads are possible
  allow_nested_items_to_be_public = true

  # Issue 2: HTTPS not enforced — data in transit can be unencrypted
  enable_https_traffic_only = false

  # Issue 3: min_tls_version not set — defaults to TLS1_0

  # Issue 4: No blob_properties block — soft delete is not configured

  tags = var.tags
}

# ── Network Security Group (contains issue 5) ────────────────────

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  # Issue 5: Wildcard inbound rule — all traffic from any source on any port
  security_rule {
    name                       = "allow-all-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# ── Key Vault (contains issues 6-7) ──────────────────────────────

resource "azurerm_key_vault" "main" {
  name                = "kv-demo-prod-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization = true
  soft_delete_retention_days = 7

  # Issue 6: Purge protection disabled — vault can be permanently deleted
  purge_protection_enabled = false

  # Issue 7: No network_acls block — Key Vault is publicly accessible

  tags = var.tags
}

# ── Outputs (contains issue 8) ───────────────────────────────────

# Issue 8: Sensitive value not marked sensitive = true
# This will print the storage key in plain text in terraform output / CI logs
output "storage_primary_key" {
  description = "Primary access key for the storage account."
  value       = azurerm_storage_account.data.primary_access_key
  # sensitive = true   ← this line is missing
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}
