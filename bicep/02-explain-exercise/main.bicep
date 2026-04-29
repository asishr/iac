// ─────────────────────────────────────────────────────────────────
// EXPLAIN EXERCISE — Key Vault + Storage with RBAC and CMK
// ─────────────────────────────────────────────────────────────────
// This file contains several patterns worth exploring with Copilot.
// Try these prompts in Copilot Chat:
//
//   1. Select entire file → /explain
//
//   2. "Explain the @secure() decorator on bootstrapSecret and why it matters.
//       What happens to the value in deployment logs without it?"
//
//   3. "What does the dependsOn on the 'secret' resource do?
//       Is it actually needed given Bicep's implicit dependency resolution?"
//
//   4. "Explain what guid() does in the role assignment name.
//       What would happen if I used a static string instead?"
//
//   5. "Identify any security concerns in this file."
//       (Expected finds: soft delete only 7 days, no private endpoint on KV,
//        no private endpoint on storage, CMK not configured on storage)
//
//   6. "I'm new to Bicep. Walk me through the var block and explain
//       why naming is derived rather than passed as params."
//
// Teaching point: Copilot as a "why" engine — not just a code generator.
// ─────────────────────────────────────────────────────────────────

@description('Short workload name used to derive all resource names.')
param workloadName string

@description('Environment shortcode.')
@allowed(['dev', 'tst', 'uat', 'prd'])
param environmentCode string

@description('Azure region shortcode for naming (e.g. eus, wus, neu).')
param locationCode string = 'eus'

@description('Object ID of the Azure AD group to grant Key Vault Administrator role.')
param keyVaultAdminGroupObjectId string

@description('Azure AD tenant ID.')
param tenantId string = subscription().tenantId

@secure()
@description('Bootstrap secret written to Key Vault on first deploy. Marked @secure() so it is redacted from deployment logs and outputs.')
param bootstrapSecret string

param location string = resourceGroup().location

param tags object = {
  env: environmentCode
  workload: workloadName
  'managed-by': 'bicep'
}

// ── Derived naming ───────────────────────────────────────────────
// Ask Copilot: "Why derive names here rather than accept them as params?"

var kvName = 'kv-${workloadName}-${environmentCode}-${locationCode}'
var storageName = 'st${workloadName}${environmentCode}${locationCode}'

// ── Key Vault ────────────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// ── Key Vault RBAC ───────────────────────────────────────────────
// Ask Copilot: "What is the Key Vault Administrator role and what does it grant?"

resource kvAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, keyVaultAdminGroupObjectId, 'KeyVaultAdministrator')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Administrator
    )
    principalId: keyVaultAdminGroupObjectId
    principalType: 'Group'
  }
}

// ── Bootstrap Secret ─────────────────────────────────────────────
// Ask Copilot: "Is the dependsOn here necessary? Explain Bicep's implicit dependencies."

resource bootstrapKvSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'bootstrap-secret'
  dependsOn: [kvAdminRole]
  properties: {
    value: bootstrapSecret
    attributes: {
      enabled: true
    }
  }
}

// ── Storage Account ──────────────────────────────────────────────

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: { enabled: true, keyType: 'Account' }
        file: { enabled: true, keyType: 'Account' }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// ── Outputs ──────────────────────────────────────────────────────

@description('URI of the deployed Key Vault.')
output keyVaultUri string = keyVault.properties.vaultUri

@description('Resource ID of the storage account.')
output storageAccountId string = storage.id

// Note: No key or connection string outputs.
// Access is granted via RBAC + managed identity — not access keys.
// Ask Copilot: "What RBAC role should I assign to allow an app to read blobs?"
