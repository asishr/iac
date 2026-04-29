# ─────────────────────────────────────────────────────────────────
# SCAFFOLD EXAMPLE — Storage Account + Private Endpoint
# ─────────────────────────────────────────────────────────────────
# Prompt used to generate this file:
#
#   "Create an Azure Storage Account for diagnostic logs.
#    Constraints:
#    - LRS replication, Standard tier
#    - Private endpoint only — no public blob access
#    - Soft delete for blobs (7 days) and containers (7 days)
#    - Minimum TLS 1.2
#    - CMK encryption via Key Vault key reference passed as variable
#    - Mandatory tags: env, owner, cost-center (validate in variables)"
#
# Compare this output to what you get from a vague prompt like "create storage".
# ─────────────────────────────────────────────────────────────────

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
  required_version = ">= 1.7"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ── Existing resources ───────────────────────────────────────────

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_key_vault_key" "cmk" {
  name         = var.cmk_key_name
  key_vault_id = var.key_vault_id
}

# ── Storage Account ──────────────────────────────────────────────

resource "azurerm_storage_account" "diag" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Disable all public access
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # Customer-managed encryption — identity required for Key Vault access
  identity {
    type = "SystemAssigned"
  }

  customer_managed_key {
    key_vault_key_id          = data.azurerm_key_vault_key.cmk.id
    user_assigned_identity_id = null
  }

  tags = var.tags
}

# ── Private Endpoint ─────────────────────────────────────────────

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-${var.storage_account_name}-blob"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.storage_account_name}-blob"
    private_connection_resource_id = azurerm_storage_account.diag.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = var.tags
}
