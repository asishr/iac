# Copilot Workspace Instructions

This repository is used for live demonstrations of GitHub Copilot with Infrastructure as Code.

## Target Cloud
Microsoft Azure

## IaC Tools
- Terraform (`hashicorp/azurerm` provider `~> 3.100`, Terraform CLI `>= 1.7`)
- Bicep (API versions `2024-03-01` or latest stable where available)

## Landing Zone Constraints
All generated resources must comply with the following:
- **Tags required on every resource:** `env`, `owner`, `cost-center`
- **No public endpoints** on storage accounts, Key Vaults, databases, or private workloads
- **Encryption at rest** required on all storage resources
- **Minimum TLS 1.2** on all endpoints
- **Soft delete** enabled on Key Vaults (90-day retention) and storage blobs/containers (7-day retention)
- **Purge protection** enabled on Key Vaults in non-dev environments
- Resources must be deployed into parameterised locations — do not hard-code region strings

## Naming Convention
`{type-abbreviation}-{workload}-{env}-{region-code}`

Examples:
- Storage account: `stworkloadprdeus` (no hyphens, max 24 chars)
- Key Vault: `kv-workload-prd-eus`
- Virtual Network: `vnet-workload-prd-eus`
- Subnet: `snet-{tier}-prd-eus`

## Terraform Conventions
- Separate files: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`
- Pin provider with `~>` (pessimistic constraint operator)
- All `variable` blocks must have `type` and `description`
- Use `validation` blocks for constrained string inputs (env codes, SKUs, etc.)
- Sensitive outputs must use `sensitive = true`
- Do not output primary access keys — use RBAC and managed identity instead

## Bicep Conventions
- Use `@description()` on every `param`
- Use `@secure()` on any param containing secrets or credentials
- Use `@allowed()` for params with a constrained value set
- Grant permissions via RBAC role assignments, not access policies
- Use `existing` keyword to reference pre-existing resources
- Role assignment names must use `guid()` for idempotency

## Security Posture
- Prefer managed identity over connection strings or access keys
- Prefer private endpoints over service endpoints
- Network ACLs default action must be `Deny` on Key Vaults and storage
- NSG rules must use specific port ranges — no wildcard `*` on destination ports for inbound rules
