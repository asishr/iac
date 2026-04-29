# DEMO EXERCISE 1 — Scaffold a Storage Account with Copilot
# ─────────────────────────────────────────────────────────
# Using Copilot, generate an Azure Storage Account that:
#   - Uses LRS replication, Standard tier
#   - Disables all public access (public_network_access_enabled = false)
#   - Enables soft-delete for blobs (7 days) and containers (7 days)
#   - Sets minimum TLS version to TLS1_2
#   - Has mandatory tags: env, owner, cost-center (use variables)
#
# Steps:
#   1. Start typing the resource block below — accept Copilot inline suggestions
#   2. In Copilot Chat, ask: "Review this storage account for security concerns"
#   3. In Copilot Chat, ask: "Extract all hard-coded values into variables"
#   4. Run: terraform validate
#
# Tip: The .github/copilot-instructions.md file in this repo gives Copilot
# the landing zone constraints automatically — you don't need to repeat them.
# ─────────────────────────────────────────────────────────

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
  features {}
}

# TODO: Add a data source or resource for the resource group

# TODO: Start typing below and let Copilot complete the storage account resource
# resource "azurerm_storage_account" "diag" {
