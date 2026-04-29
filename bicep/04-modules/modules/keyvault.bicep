// Key Vault Module — placeholder
// ────────────────────────────────
// This file is intentionally minimal.
// Let Copilot generate the full module during Exercise 4.
//
// Prompt: "Fill out this Bicep module for an Azure Key Vault.
// Params: workloadName, environmentCode, locationCode, tenantId, adminGroupObjectId, tags.
// Enable RBAC auth, soft delete (90 days), purge protection.
// Public network access: Disabled. Network ACLs default: Deny, bypass: AzureServices.
// Grant adminGroupObjectId the Key Vault Administrator role.
// Outputs: keyVaultId, keyVaultUri."

@description('Short workload name.')
param workloadName string

@description('Environment shortcode (dev/tst/uat/prd).')
param environmentCode string

@description('Region shortcode used in naming.')
param locationCode string = 'eus'

param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('Object ID of the AAD group to grant Key Vault Administrator.')
param adminGroupObjectId string

@description('Mandatory tags.')
param tags object

// TODO: Let Copilot fill in the rest
