// DEMO EXERCISE 4 — Bicep Modules
// ─────────────────────────────────────────────────────────────────
// Bicep modules let you package reusable resource definitions and
// compose them in a parent template. This exercise has no direct
// Terraform equivalent in this repo — it's Bicep-specific.
//
// Exercise: use Copilot to create a reusable 'storage' module and
// consume it from this parent template.
//
// Step 1 — Ask Copilot Chat:
//   "Create a reusable Bicep module in modules/storage.bicep for an
//    Azure Storage Account that:
//    - Takes params: workloadName, environmentCode, location, tags
//    - Derives the storage account name from those params using var
//    - Disables public access, enforces HTTPS, sets TLS 1.2
//    - Enables blob soft delete (7 days)
//    - Returns outputs: storageAccountId, storageAccountName"
//
// Step 2 — Ask Copilot Chat:
//   "Now update this main.bicep to consume that module twice:
//    once for 'app' tier storage and once for 'logs' tier storage,
//    using different params for each."
//
// Step 3 — Ask Copilot Chat:
//   "Add a second module call that deploys a Key Vault using a
//    modules/keyvault.bicep module. Grant the storage account's
//    managed identity the Key Vault Secrets User role."
//
// Teaching points:
//   - Modules enforce separation of concerns and reuse
//   - Parent template wires modules together; no resource details leak up
//   - Ask: "What is the difference between a Bicep module and a Bicep file?"
//   - Ask: "How does a Bicep module registry work and when should I use one?"
// ─────────────────────────────────────────────────────────────────

@description('Short workload name used to derive resource names.')
param workloadName string

@description('Environment shortcode.')
@allowed(['dev', 'tst', 'uat', 'prd'])
param environmentCode string

@description('Azure region shortcode for naming.')
param locationCode string = 'eus'

param location string = resourceGroup().location

@description('Mandatory resource tags: env, owner, cost-center.')
param tags object

// ── App-tier storage (consume a module here) ─────────────────────
// TODO: Call modules/storage.bicep for the 'app' tier
// module appStorage 'modules/storage.bicep' = {
//   name: 'deploy-app-storage'
//   params: { ... }
// }

// ── Logs-tier storage (consume the same module, different params) ─
// TODO: Call modules/storage.bicep for the 'logs' tier
// module logsStorage 'modules/storage.bicep' = {
//   name: 'deploy-logs-storage'
//   params: { ... }
// }

// ── Key Vault (consume a second module here) ──────────────────────
// TODO: Call modules/keyvault.bicep
// module kv 'modules/keyvault.bicep' = {
//   name: 'deploy-keyvault'
//   params: { ... }
// }

// ── Outputs ──────────────────────────────────────────────────────
// TODO: Surface module outputs up to the parent template
