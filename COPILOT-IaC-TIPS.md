# GitHub Copilot for IaC — Tips and Techniques

Practical, battle-tested guidance for getting the most out of GitHub Copilot when writing Bicep, Terraform, or any infrastructure-as-code.

---

## Contents

1. [Set the stage — workspace context](#1-set-the-stage--workspace-context)
2. [Write prompts that produce deployable output](#2-write-prompts-that-produce-deployable-output)
3. [Completion vs Chat — when to use each](#3-completion-vs-chat--when-to-use-each)
4. [Understand before you ship — /explain patterns](#4-understand-before-you-ship--explain-patterns)
5. [Security review workflow](#5-security-review-workflow)
6. [Refactoring with Copilot](#6-refactoring-with-copilot)
7. [Module and component generation](#7-module-and-component-generation)
8. [Azure Verified Modules (AVM)](#8-azure-verified-modules-avm)
9. [Iterative prompt sequences](#9-iterative-prompt-sequences)
10. [Common pitfalls and how to avoid them](#10-common-pitfalls-and-how-to-avoid-them)
11. [Pipeline integration](#11-pipeline-integration)
12. [Quick-win checklist](#12-quick-win-checklist)

---

## 1. Set the Stage — Workspace Context

The single highest-leverage thing you can do is tell Copilot about your environment **once**, so you never have to repeat it per prompt.

### Create `.github/copilot-instructions.md`

This file is automatically loaded into every Copilot Chat interaction in the workspace. Put your standing constraints here:

```markdown
## Landing Zone Constraints
- Tags required on every resource: env, owner, cost-center
- No public endpoints on storage, Key Vault, databases
- Minimum TLS 1.2 on all endpoints
- RBAC only — no access policies or connection strings
- Encryption at rest on all storage

## Naming Convention
{type}-{workload}-{env}-{region}
Examples: kv-orders-prd-eus, vnet-platform-prd-eus

## IaC Standard
Bicep. API versions: 2024-03-01 or latest stable.
Use @description() on every param. Use @secure() for secrets.
Use guid() for role assignment resource names.
```

**Result:** Every generated resource block follows your naming and security posture without you repeating it in each prompt. This is especially valuable when onboarding new team members — Copilot acts as an always-on policy enforcer.

### Keep relevant files open in editor tabs

Copilot's inline completion reads your open tabs for context. Before generating a new resource:
- Open the file that already defines related resources in the same stack
- Open the `variables.tf` / parameters file so Copilot knows what values are already declared
- Open any existing module that the new resource will call

---

## 2. Write Prompts that Produce Deployable Output

### The structured comment pattern

The most reliable trigger for high-quality completions is a structured comment block immediately before the resource declaration. Copilot treats the comment as a specification.

**Bicep:**
```bicep
// Create an Azure Key Vault for the orders workload.
// Requirements:
//   - RBAC authorization mode (no access policies)
//   - Public network access disabled
//   - Soft delete: 90 days, purge protection enabled
//   - System-assigned managed identity
//   - Tags from var tags
// Name: kv-orders-${environmentCode}-${locationCode}
resource ordersKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
```

**Terraform:**
```hcl
# Create an Azure Key Vault for the orders workload.
# Requirements:
#   - RBAC authorization (enable_rbac_authorization = true)
#   - Public network access disabled
#   - Soft delete retention: 90 days, purge_protection_enabled = true
#   - Tags from var.tags
resource "azurerm_key_vault" "orders" {
```

### Front-load constraints in Chat prompts

When using Copilot Chat, lead with context and constraints before stating what you want:

```
Context: regulated Azure landing zone, Bicep, no public endpoints, RBAC only.
Generate a resource block for an Azure Storage Account:
- Disable public blob access
- Enforce HTTPS, minimum TLS 1.2
- Enable blob soft delete (7 days)
- System-assigned identity
- Tags from the `tags` param already declared in this file
```

Contrast this with a weak prompt:
```
create a storage account
```

The weak prompt produces something that compiles but fails security review. The structured prompt produces something close to production-ready.

### Specify what you already have

Copilot doesn't know what variables or parameters already exist unless you tell it (or they're in an open tab). Be explicit:

```
Using the params already declared in this file (workloadName, environmentCode,
locationCode, location, tags), generate a Key Vault resource block.
Derive the vault name using var inside the resource block.
```

---

## 3. Completion vs Chat — When to Use Each

| Situation | Use |
|---|---|
| Generating a new resource block | **Completion** — write the comment + opening line, accept suggestions |
| Filling in a known pattern (output, variable, param) | **Completion** — start typing, Tab through |
| Asking "why" about existing code | **Chat** — `/explain` or targeted question |
| Multi-step refactoring | **Chat** — run the 3-step sequence (see §6) |
| Security review of a whole file | **Chat** — select all, then ask |
| Generating a module skeleton | **Chat** — describe inputs/outputs/requirements |
| Translating between languages (ARM → Bicep, HCL → Bicep) | **Chat** — paste source, ask for conversion |
| Checking AVM module paths and versions | **Chat** — ask by resource type |

### Copilot Chat slash commands for IaC

| Command | Use case |
|---|---|
| `/explain` | Understand what selected code does and why |
| `/fix` | Fix a syntax or logic error in selected code |
| `/doc` | Generate `@description()` decorators or inline comments for selected params |
| `/tests` | Generate a Pester or Terratest test for a module |

---

## 4. Understand Before You Ship — /explain Patterns

Copilot is a powerful learning and documentation tool, not just a code generator.

### Whole-file explanation

Select all (`Ctrl+A`) → Copilot Chat:
```
/explain
```

Use this on inherited files, vendor-provided templates, or any file your team doesn't fully own.

### Targeted "why" questions

Don't just ask what code does — ask why it's written that way, and what breaks if you change it:

```
What does the dependsOn on this resource do?
Is it needed given Bicep's implicit dependency resolution,
or is it defensive documentation?
```

```
What is the purpose of guid() in this role assignment name?
What happens if I deploy this template twice to the same scope?
```

```
What does @secure() on this param actually prevent?
Where would the value appear in deployment logs without it?
```

### Onboarding pattern

For new team members or unfamiliar files:
```
I'm new to Bicep. Walk me through this file:
- What resources does it create and in what order?
- Which params are required vs have defaults?
- What would break if I removed the dependsOn on line X?
```

---

## 5. Security Review Workflow

Copilot can act as a first-pass security reviewer. It won't replace PSRule for Azure or Defender for DevOps, but it catches common issues instantly.

### The review prompt

Select the entire file, then:
```
Review this Bicep file for security concerns and missing Azure best practices.
List findings as a table: Severity | Issue | Line (approx) | Recommendation
```

### Issues Copilot reliably catches

- Public blob access enabled on storage accounts
- `supportsHttpsTrafficOnly: false` or missing
- Minimum TLS not set or set below 1.2
- Key Vault with no soft delete or purge protection
- NSG rules with wildcard `*` on destination ports
- Outputs that expose connection strings or primary keys
- Role assignments using broad built-ins (Owner, Contributor) where a specific role would do
- Missing tags

### Issues that still need human + tooling review

- Correct least-privilege role selection (Copilot often suggests `Contributor`)
- Network topology correctness (subnet CIDR overlaps, peering rules)
- Cross-subscription RBAC and policy inheritance
- Secrets rotation strategy

### Fix workflow

After getting the findings table:
```
Fix the storage account section to address findings 1, 2, and 3.
Show only the changed lines with before/after context.
```

Then validate immediately:
```bash
az bicep build --file main.bicep
```

---

## 6. Refactoring with Copilot

### The 3-step extraction sequence

Use this when a file has hard-coded values, repeated literals, or no parameterisation. Run each step separately, review the output, then proceed.

**Step 1 — Audit:**
```
Identify all hard-coded values in this file that should be params or vars.
List as a table: name | current value | suggested type (param/var) | reason
```

**Step 2 — Declare:**
```
Generate param and var declarations for all items in that table.
For Bicep: add @description() to every param, @allowed() where the value
has a constrained set. For Terraform: add type and description to every variable,
add validation blocks for constrained inputs.
```

**Step 3 — Replace:**
```
Update the resource blocks to reference the new params and vars
instead of hard-coded values. Use var/local for derived or computed values.
```

Three separate outputs = three reviewable diffs. This mirrors PR discipline.

### ARM → Bicep migration

```
Convert this ARM JSON template to Bicep.
Use the existing keyword where resources already exist in the target scope.
Replace API versions older than 2022-01-01 with the latest stable version.
```

### Terraform → Bicep translation

```
Translate this Terraform resource block to a Bicep resource block.
Preserve all properties. Note any features that don't have a direct Bicep equivalent.
```

---

## 7. Module and Component Generation

### Generating a module skeleton

Rather than generating a complete module in one shot, give Copilot the contract first:

```
Create a Bicep module for an Azure Storage Account with these inputs:
  Params: workloadName (string), environmentCode (string, @allowed dev/staging/prod),
          locationCode (string), location (string), tags (object)
  Requirements: enforce HTTPS, TLS 1.2, no public access, soft delete 7 days,
                system-assigned identity
  Outputs: storageAccountId, storageAccountName, principalId
Derive the storage account name inside the module as a var.
Do not accept the name as a param.
```

The "do not accept name as a param" instruction is important — it forces naming convention enforcement at the module level rather than trusting the caller.

### Wiring modules together (output → input)

```
I have two modules:
- storage.bicep outputs: storageAccountId, principalId
- keyvault.bicep params include: identityPrincipalId

In main.bicep, add a module call for keyvault.bicep.
Pass the principalId from the storage module as identityPrincipalId.
Grant the identity the Key Vault Secrets User role on the Key Vault.
```

### Generating outputs

```
Generate outputs for all resources in this file.
Use resource symbolic names, not string concatenation.
Mark any outputs containing sensitive values with sensitive = true (Terraform)
or add a // SENSITIVE comment with a recommendation to remove (Bicep).
```

---

## 8. Azure Verified Modules (AVM)

AVM modules are Microsoft-published, WAF-aligned Bicep modules available from the public registry at `br/public:avm/res/<provider>/<resource>:<version>`. They encode best practices as defaults.

Registry: [aka.ms/avm](https://aka.ms/avm)

### Discover a module

```
What is the AVM registry path for an Azure Storage Account?
What is the latest stable version and what are the minimum required parameters?
```

### Generate a module block

```
Generate a Bicep module block using the AVM Storage Account module
(br/public:avm/res/storage/storage-account) for the orders workload.
Use location and tags from the params in this file.
Enable blob soft delete for 7 days.
```

### Understand what AVM gives you for free

```
If I use the AVM Storage Account module instead of writing the resource block directly,
which Azure security best practices are applied automatically by the module defaults?
Which settings still require explicit configuration?
```

### Use the standardised AVM interface

Every AVM resource module accepts the same cross-cutting parameters. Ask Copilot to fill them:

```
Add a resource lock (CanNotDelete), diagnostic settings sending all logs to a
Log Analytics workspace, and a roleAssignments entry granting the app identity
the Storage Blob Data Reader role — using only the AVM module's built-in parameters.
```

### Version management

```
What changed between AVM storage-account module versions 0.8.0 and 0.9.0?
Are there any breaking parameter changes I need to handle before upgrading?
```

---

## 9. Iterative Prompt Sequences

### When to iterate

Copilot's first output is rarely final. Think of it as a first draft that you refine through follow-up prompts — the same way you'd iterate in a code review.

### Effective follow-up patterns

**Add what's missing:**
```
The generated block is missing a system-assigned identity and a scale rule.
Add both without changing anything else.
```

**Constrain something:**
```
The network ACL defaultAction is 'Allow'. Change it to 'Deny' and add
the bypass rules needed for Azure services and logging.
```

**Explain a choice:**
```
You used the Owner role in the role assignment. What is the minimum
permission needed for this use case, and what specific role should I use instead?
```

**Ask for alternatives:**
```
Show me two ways to pass the storage account name to the app service:
1. Using an app setting referencing a Key Vault secret
2. Using a managed identity with Storage Blob Data Reader role
Which is recommended for a regulated workload?
```

### Don't chain too many requirements into one prompt

**Harder for Copilot:**
```
Create a complete multi-tier application with VNet, subnets, NSGs, storage,
Key Vault, App Service, managed identity, RBAC, private endpoints, and diagnostics.
```

**Better approach:** break into separate prompts — networking, then compute, then storage, then RBAC. Each output is reviewable and buildable before proceeding.

---

## 10. Common Pitfalls and How to Avoid Them

### API version drift

Copilot is trained on public code. Older API versions appear frequently in training data and may be suggested. Always check:

```
What is the latest stable API version for Microsoft.KeyVault/vaults?
Are there any new properties in versions after 2022-07-01 that I should use?
```

Validate against [learn.microsoft.com/azure/templates](https://learn.microsoft.com/en-us/azure/templates/) before merging.

### Broad RBAC roles

Copilot frequently suggests `Contributor` or `Owner` because they're common in training data. Always ask:

```
What is the minimum RBAC role this identity needs to [specific operation]?
Is there a built-in role more specific than Contributor?
```

### Outputs exposing secrets

Copilot will sometimes output connection strings or primary keys because they appear in many examples. Always check outputs:

```
Review the outputs in this file. Do any of them expose values that should
be kept secret? What is the recommended pattern to replace each one?
```

### Placeholder values

Copilot occasionally generates placeholder strings like `"your-subscription-id"` or `"<replace-me>"`. Run:

```
Scan this file for any placeholder, example, or hard-coded values
that would cause a deployment failure. List them.
```

### Missing `@secure()` on sensitive params

```
Which params in this file hold passwords, connection strings, or SAS tokens?
Should any of them have @secure() added?
```

---

## 11. Pipeline Integration

Copilot generates the code; your pipeline validates it. This boundary is non-negotiable.

### Recommended pipeline gates

```
[Copilot] → draft resource block or module
     ↓
[az bicep build]                  — syntax validation, catch immediately
     ↓
[az deployment what-if]           — verify intent before any real change
     ↓
[PSRule for Azure / tflint]       — policy gate, mandatory in CI
     ↓
[Checkov / Trivy]                 — security scanning
     ↓
[PR review]                       — human judgment on design
     ↓
[Pipeline deploy]                 — approved change applied
```

### Generating pipeline config with Copilot

```
Generate a GitHub Actions workflow that:
1. Runs az bicep build on all changed .bicep files
2. Runs PSRule for Azure on the bicep/ directory
3. Runs az deployment what-if against the dev resource group on PR
4. Deploys to dev on merge to main
Uses OpenID Connect (federated identity) — no stored credentials.
```

### Generate the what-if command

```
Generate the az deployment group what-if command for main.bicep
with the parameters from main.parameters.json,
targeting resource group rg-orders-dev-eus.
```

---

## 12. Quick-Win Checklist

Before starting any IaC session with Copilot, verify:

- [ ] `.github/copilot-instructions.md` exists and contains your landing zone constraints, naming convention, and IaC standard
- [ ] Relevant context files are open in editor tabs (variables, existing modules, parent template)
- [ ] You know the latest stable API version for the resource you're generating

Per resource block generated:

- [ ] No hard-coded region strings (use params)
- [ ] Tags applied from a param or var
- [ ] No public endpoint unless explicitly required
- [ ] HTTPS / TLS minimum explicitly set on network-facing resources
- [ ] No connection strings or keys in outputs
- [ ] `@secure()` on any param holding credentials
- [ ] Role assignment name uses `guid()` for idempotency
- [ ] `az bicep build` passes before committing

Before merging:

- [ ] `az deployment what-if` reviewed and intent confirmed
- [ ] PSRule for Azure (or tflint) passes
- [ ] No `Contributor` or `Owner` role assignments without documented justification
- [ ] Outputs reviewed for accidental secret exposure

---

## Further Reading

- [Azure Verified Modules](https://aka.ms/avm) — pre-built WAF-aligned Bicep modules
- [PSRule for Azure](https://azure.github.io/PSRule.Rules.Azure/) — policy-as-code for Bicep and ARM
- [Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Resource reference](https://learn.microsoft.com/azure/templates/) — canonical API versions and properties
- [GitHub Copilot docs — workspace instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot)
