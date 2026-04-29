# DEMO EXERCISE 2 — Refactor: Extract Hard-Coded Values
# ──────────────────────────────────────────────────────
# This file has multiple hard-coded values that should be variables.
#
# Use Copilot Chat with this three-step prompt sequence:
#
# Step 1 — Identify:
#   "Identify all hard-coded values in this file that should be variables.
#    List them as a table: name | current value | suggested type | description"
#
# Step 2 — Generate variables:
#   "Generate variable declarations for all items in that table.
#    Add validation blocks where the value has a constrained set of options."
#
# Step 3 — Update references:
#   "Update the resource blocks in this file to reference the new variables
#    instead of the hard-coded values."
#
# Teaching point: Three prompts, three reviewable outputs — mirrors PR discipline.
# ──────────────────────────────────────────────────────

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

resource "azurerm_resource_group" "main" {
  name     = "rg-demo-prod-eastus"
  location = "eastus"

  tags = {
    env         = "prod"
    owner       = "platform-team"
    cost-center = "cc-1234"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-demo-prod-eastus"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  dns_servers         = ["168.63.129.16"]

  tags = {
    env         = "prod"
    owner       = "platform-team"
    cost-center = "cc-1234"
  }
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-prod-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  tags = {
    env         = "prod"
    owner       = "platform-team"
    cost-center = "cc-1234"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
