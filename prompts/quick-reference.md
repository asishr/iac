# Copilot Prompt Quick Reference — IaC (Bicep)
### Keep this open during the session

---

## Scaffold — Generate a new resource

```bicep
// Create [resource type] for [purpose].
// Constraints:
//   - [constraint 1]
//   - [constraint 2]
//   - [constraint 3]
// Tags: env, owner, cost-center
// No public endpoints
resource myResource 'Microsoft.[Provider]/[type]@[api-version]' = {
```

**Add decorators upfront:**
```bicep
@description('Purpose of this parameter')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environmentCode string

@secure()
param adminPassword string
```

---

## Explain — Understand existing code

```
/explain
```
*(Select code first, then type in Copilot Chat)*

Or more targeted:
```
Explain what this [lifecycle block / dependsOn / NSG rule] does
and identify any risks with this pattern in a GitOps workflow.
```

---

## Security Review — Find issues

```
Review this file for security concerns and missing Azure best practices.
List findings as: Severity | Issue | Recommendation
```

---

## Refactor — Extract hard-coded values (3-step sequence)

**Step 1:**
```
Identify all hard-coded values in this file that should be variables.
List as a table: name | current value | suggested type | description
```

**Step 2:**
```
Generate variable declarations for all items in that table.
Add validation blocks where the value has a constrained set of options.
```

**Step 3:**
```
Update the resource blocks to reference the new variables instead of hard-coded values.
```

---

## Policy-Aware Generation — Encode guardrails upfront

```
Context: regulated Azure landing zone
Constraints:
  - Tags required on every resource: env, owner, cost-center
  - No public endpoints
  - Encryption at rest required on all storage
  - Minimum TLS 1.2

Generate: [resource description] that meets all of these constraints.
```

---

## Bicep-Specific Patterns

**Derive naming inside a module (enforce conventions):**
```bicep
var storageAccountName = 'st${workloadName}${environmentCode}${locationCode}'
```

**Reference an existing resource (no redeploy):**
```bicep
resource existingKv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}
```

**Cross-module output/input wiring:**
```
The storage module outputs principalId.
Wire that into the keyvault module as the identityPrincipalId param.
Grant it the Key Vault Secrets User role.
```

**Idempotent role assignment:**
```bicep
name: guid(resourceGroup().id, app.id, roleDefId)
```

---

## Translate — ARM to Bicep

```
Convert this ARM template snippet to Bicep.
Use the existing keyword where resources already exist.
```

---

## Terraform Reference (comparison only)

```hcl
# Create [resource type] for [purpose].
# Constraints: [list]
resource "azurerm_..." "..." {
```

---

## Test Scaffolding — Generate tests

**Terratest (Go):**
```
Generate a Terratest skeleton for this module that:
1. Deploys to a temporary resource group with a random suffix
2. Asserts [property] equals [expected value]
3. Defers resource group deletion even if the test fails
```

**Pester (Bicep/PowerShell):**
```
Generate a Pester test that validates this Bicep template deploys
successfully using New-AzResourceGroupDeployment -WhatIf
and checks that outputs contain the expected values.
```

---

## Document — Add descriptions and README stubs

```
Add @description() decorators to all params in this Bicep file
that are currently missing them.
```

```
Add description and type fields to all variable blocks in this
Terraform file that are missing them.
```

```
Generate a README for this Terraform module that documents:
inputs, outputs, usage example, and any prerequisites.
```

---

## Onboarding / Learning

```
I'm new to Bicep. Walk me through this file section by section,
explaining what each decorator (@secure, @description, @allowed) does.
```

```
What are the trade-offs between using a Bicep module registry versus
local modules for a team of 20 engineers?
```

```
Why does azurerm_subnet require a separate NSG association resource
rather than an inline nsg_id argument?
```

---

## Boundaries — Where to be careful

| Scenario | Recommended extra step |
|----------|------------------------|
| IAM / RBAC assignments | Verify role is least-privilege; cross-check Azure docs |
| NSG / firewall rules | Run Checkov/tfsec after generation |
| Secret handling | Ensure `sensitive = true`; never output raw keys |
| `lifecycle` blocks | Require explicit team review |
| Provider version pins | Verify constraint operator (`~>`) against tested version |
