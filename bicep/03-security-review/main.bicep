// DEMO EXERCISE 3 — Security Review
// ────────────────────────────────────
// This file contains deliberate security issues for the audience to find
// — with Copilot's help.
//
// Prompt to use in Copilot Chat:
//   "Review this Bicep file for security concerns and missing Azure best practices.
//    List findings as: Severity | Issue | Recommendation"
//
// Issues hidden in this file (presenter reference — 8 total):
//   1.  [HIGH]   Storage: public blob access allowed
//   2.  [HIGH]   Storage: HTTP traffic allowed (supportsHttpsTrafficOnly missing)
//   3.  [HIGH]   Storage: minimum TLS not set (defaults to TLS 1.0)
//   4.  [MEDIUM] Storage: no blob soft delete configured
//   5.  [HIGH]   NSG: allow-all inbound rule (wildcard source + port)
//   6.  [HIGH]   Key Vault: purge protection disabled
//   7.  [MEDIUM] Key Vault: publicNetworkAccess = 'Enabled' with no network ACLs
//   8.  [HIGH]   Output: storage connectionString is sensitive but no @secure() param used to receive it
//
// Teaching point:
//   - Copilot is a fast first-pass reviewer
//   - Does NOT replace PSRule for Azure or Azure Policy in your pipeline
//   - Ask: "Which of these findings would PSRule for Azure catch automatically?"
// ────────────────────────────────────

@description('Name of the resource group to deploy into.')
param resourceGroupName string

@description('Azure region for all resources.')
param location string = 'eastus'

@description('Azure AD tenant ID.')
param tenantId string = subscription().tenantId

@description('Resource tags.')
param tags object = {}

// ── Storage Account (issues 1–4) ─────────────────────────────────

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stdemoproddata001'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    // Issue 1: Public blob access allowed — anonymous reads possible
    allowBlobPublicAccess: true

    // Issue 2: HTTPS not enforced — plaintext traffic accepted
    // supportsHttpsTrafficOnly: true   ← missing

    // Issue 3: minimumTlsVersion not set — defaults to TLS 1.0

    // Issue 4: No blob service soft delete configured
  }
}

// ── NSG (issue 5) ────────────────────────────────────────────────

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-web'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        // Issue 5: Wildcard inbound — all traffic on all ports from any source
        name: 'allow-all-inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// ── Key Vault (issues 6–7) ───────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-demo-prod-001'
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
    softDeleteRetentionInDays: 7

    // Issue 6: Purge protection disabled — vault can be permanently deleted
    enablePurgeProtection: false

    // Issue 7: Public network access open with no network ACLs
    publicNetworkAccess: 'Enabled'
    // networkAcls block is missing entirely
  }
}

// ── Outputs (issue 8) ────────────────────────────────────────────

// Issue 8: Connection string contains a secret — should never be output.
// Access should be granted via RBAC + managed identity, not connection strings.
// If this output is consumed by a caller, the secret flows into deployment logs.
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

output keyVaultUri string = keyVault.properties.vaultUri
