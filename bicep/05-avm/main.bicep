// EXERCISE 6 — Consume Azure Verified Modules (AVM)
// ────────────────────────────────────────────────────────────────────
// Azure Verified Modules (AVM) are Microsoft-published, WAF-aligned,
// pre-built Bicep modules available from the public Bicep registry.
// Registry: https://aka.ms/avm
//
// Instead of writing resource blocks by hand, you reference a versioned
// AVM module and supply only the parameters your workload needs.
// AVM enforces best practices (TLS, HTTPS, soft delete, RBAC, tags)
// as module defaults — you override only what you intend to change.
//
// Registry path format:
//   br/public:avm/res/<resource-provider>/<resource-type>:<version>
//
// ────────────────────────────────────────────────────────────────────
// PART A — Discovery with Copilot
// ────────────────────────────────────────────────────────────────────
// Try these prompts in Copilot Chat:
//
//   1. "What is the Azure Verified Modules registry path for a Storage Account?
//       What is the latest stable version as of today?"
//
//   2. "What are the required parameters for the AVM Storage Account module?
//       Show me the minimum viable module block."
//
//   3. "How does the AVM Storage Account module handle private endpoints?
//       What parameter controls that, and what does it expect?"
//
// ────────────────────────────────────────────────────────────────────
// PART B — Compare: hand-written vs AVM
// ────────────────────────────────────────────────────────────────────
// Open bicep/03-security-review/main.bicep alongside this file.
// That file required you to find 8 security issues manually.
//
// Ask Copilot Chat:
//   "If I use the AVM Storage Account module instead of writing the
//    resource block directly, which of those 8 issues are addressed
//    automatically by AVM defaults?"
//
// ────────────────────────────────────────────────────────────────────
// PART C — Write the module blocks (guided by Copilot)
// ────────────────────────────────────────────────────────────────────
// Step 1 — Ask Copilot Chat:
//   "Generate a Bicep module block that uses the AVM Storage Account
//    module (br/public:avm/res/storage/storage-account) to deploy a
//    storage account with:
//    - Name derived from: 'st${workloadName}${environmentCode}'
//    - Location and tags from params
//    - Blob soft delete enabled (7 days)
//    - Private endpoint disabled for this exercise
//    Show the module block and any required params."
//
// Step 2 — Ask Copilot Chat:
//   "Now add an AVM Key Vault module block (br/public:avm/res/key-vault/vault).
//    Use RBAC authorization mode.
//    Grant the storage account's managed identity the Key Vault Secrets User role
//    using the AVM module's roleAssignments parameter."
//
// Step 3 — Ask Copilot Chat:
//   "What standard parameters do ALL AVM resource modules accept?
//    Show me how to use the 'lock' and 'diagnosticSettings' parameters
//    on one of these module blocks."
//
// ────────────────────────────────────────────────────────────────────
// PART D — Versioning and upgrade
// ────────────────────────────────────────────────────────────────────
// Ask Copilot Chat:
//   "How do I check if there is a newer version of an AVM module available?
//    What is the recommended strategy for pinning AVM module versions in a
//    production repository?"
//
// ────────────────────────────────────────────────────────────────────
// Teaching points:
//   - AVM = hand-written resource + policy + RBAC + diagnostics, pre-tested
//   - WAF-alignment is built in — you don't have to encode it yourself
//   - All AVM modules have a standardized interface: lock, tags,
//     roleAssignments, diagnosticSettings, privateEndpoints
//   - Copilot + AVM is faster AND more secure than Copilot + raw resources
//   - AVM versions are semver — pin to a version, review upgrade notes
// ────────────────────────────────────────────────────────────────────

targetScope = 'resourceGroup'

// ── Parameters ────────────────────────────────────────────────────

@description('Short workload name used for resource naming.')
@minLength(2)
@maxLength(10)
param workloadName string

@description('Environment code used for resource naming and tagging.')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environmentCode string

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Mandatory resource tags.')
param tags object = {
  env: environmentCode
  owner: 'platform-team'
  'cost-center': 'shared'
}

// ── TODO: Replace the placeholders below with AVM module blocks ───
// Use the Copilot prompts in PART C above to fill these in.

// Example structure (do not use as-is — let Copilot generate the full block):
//
// module storageAccount 'br/public:avm/res/storage/storage-account:<version>' = {
//   name: 'storageAccountDeployment'
//   params: {
//     name: 'st${workloadName}${environmentCode}'
//     location: location
//     tags: tags
//     // ... additional params from Copilot
//   }
// }

// ── Outputs ───────────────────────────────────────────────────────
// TODO: Add outputs for storageAccountResourceId and keyVaultResourceId
// after Copilot fills in the module blocks above.
