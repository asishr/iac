# DEMO SCRIPT — Session 2: GitHub Copilot in the IDE for IaC
### Presenter Guide · Bicep Focus

---

## Before You Start

- Clone repo, open in VS Code
- Ensure Copilot Chat panel is visible (`Ctrl+Alt+I`)
- Have a second monitor/window for showing Copilot Chat responses
- Open these files in tabs before presenting:
  - `.github/copilot-instructions.md`
  - `bicep/00-start-here/main.bicep`
  - `bicep/01-scaffold-example/main.bicep`
  - `bicep/02-explain-exercise/main.bicep`
  - `bicep/02-refactor-before/main.bicep`
  - `bicep/03-security-review/main.bicep`
  - `bicep/04-modules/main.bicep`
  - `bicep/05-avm/main.bicep`

---

## Module 1: Setting Up for Success (~10 min)

### Talking Points

> "Before Copilot writes a single line, the context it has determines the quality of what it produces. Let me show you three things that make an immediate difference."

**Step 1 — Show `.github/copilot-instructions.md`**

Open the file. Walk through each section:
- Landing zone constraints encoded as text
- Naming conventions (`kv-{workload}-{env}-{region}`)
- Mandatory tags, TLS requirements, network posture

> "This file is loaded into Copilot's context automatically for every chat interaction in this workspace. Think of it as a standing brief to your pair-programmer. You don't have to repeat 'no public endpoints' in every prompt — it's already there. For a team maintaining 50 Bicep files, this is significant."

**Step 2 — Show `.vscode/extensions.json`**

> "When a teammate clones this repo and opens it in VS Code, they're prompted to install the Bicep extension. That extension gives Copilot richer understanding — API version awareness, resource type completion, go-to-definition. All of this becomes additional context for suggestions."

**Step 3 — Open related files side by side**

Open `bicep/01-scaffold-example/main.bicep` alongside `bicep/01-scaffold-example/main.parameters.json`.

> "Copilot sees everything in your open editor tabs. Open the files you want it to reason about."

---

## Module 2: Prompting Patterns (~20 min)

### Pattern 1 — Weak vs. Strong Prompts

**Open `bicep/00-start-here/main.bicep`**

> "The comment block at the top describes exactly what we want to build. Let me first show what a weak prompt produces, then use the structured version."

**Weak prompt** — type at the bottom of the file:
```bicep
// create a container app
resource app 'Microsoft.App/containerApps@2024-03-01' = {
```

Let Copilot complete. Show the output — likely missing ingress, scale rules, identity.

> "It created *something*. But notice what's missing: no ingress config, no scale rules, no managed identity, no Dapr. This is fixable, but now you're in a discovery loop instead of a validation loop."

**Strong prompt** — undo, then use the comment already in the file. Start typing:
```bicep
resource ordersApp 'Microsoft.App/containerApps@2024-03-01' = {
```

Accept completions. Walk through what Copilot includes this time.

> "The quality of the output is a direct function of the quality of the prompt. The structured comment at the top is the prompt."

**Switch to `bicep/01-scaffold-example/main.bicep`**

> "Here's the completed version — the comment at the top shows the exact prompt used. Notice `guid()` in the role assignment name. Let's ask Copilot to explain that."

In Copilot Chat:
```
Explain why guid() is used in the role assignment resource name
and what would happen if I used a static string instead.
```

> "Idempotency — every IaC practitioner needs this intuition. Copilot explained it better than most documentation."

---

### Pattern 2 — Policy-Aware Generation

> "One prompting technique that cuts review time significantly."

In Copilot Chat:
```
Context: regulated Azure landing zone
Constraints:
  - Tags required: env, owner, cost-center
  - No public endpoints
  - Encryption at rest on all storage
  - Minimum TLS 1.2
  - RBAC only — no Key Vault access policies

Generate a Bicep resource block for an Azure Key Vault
that meets all of these constraints.
```

> "When you front-load constraints, Copilot encodes your policy as code rather than leaving compliance as a post-review discovery step."

Compare the output to `bicep/03-security-review/main.bicep` — show the contrast.

---

### Pattern 3 — Iterative Refactoring (3-step sequence)

**Open `bicep/02-refactor-before/main.bicep`**

> "Real Bicep files accumulate hard-coded values. I'll use three prompts — each produces a reviewable output."

**Step 1 — in Copilot Chat:**
```
Identify all hard-coded values in this Bicep file that should be params or vars.
List as a table: name | current value | suggested type (param/var) | description
```

Show table. Ask: "Did it miss anything?"

**Step 2:**
```
Generate param declarations for all items marked 'param' in that table.
Add @allowed() decorators where the value has a constrained set of options.
Add @description() to every param.
```

> "Notice @allowed() — Bicep's equivalent of Terraform's validation block."

**Step 3:**
```
Update the resource blocks to reference the new params and vars
instead of hard-coded values. Use var for any values derived from params.
```

> "Three prompts, three reviewable outputs. This mirrors PR discipline."

---

## Module 3: Explain and Learn (~15 min)

### Demo 1 — The "Why" Engine

**Open `bicep/02-explain-exercise/main.bicep`**

Select the entire file → Copilot Chat:
```
/explain
```

> "Every team has files only one person truly understands. Copilot gives everyone a starting point."

After the explanation, drill in with targeted questions:

**Question 1:**
```
What does the @secure() decorator on bootstrapSecret do?
What happens to the value in deployment logs without it?
```

> "Without @secure(), the value appears in plain text in ARM deployment history — accessible to anyone with read access to the resource group. This is a real finding in production environments."

**Question 2:**
```
What does the dependsOn on the 'bootstrapKvSecret' resource do?
Is it actually needed given Bicep's implicit dependency resolution?
```

> "Answer: it's redundant — the parent relationship already creates an implicit dependency. But it's explicit documentation of intent. This discussion normally takes 10 minutes in a PR; we just had it in 30 seconds."

**Question 3:**
```
What is the purpose of guid() in the role assignment name,
and what happens if I deploy this twice to the same scope?
```

**Question 4 — Learning prompt:**
```
I'm new to Bicep. What is the difference between a param and a var in this file,
and how do I decide which one to use?
```

> "Copilot as onboarding tool. New engineers can /explain any file and get a tutor."

---

### Demo 2 — Security Review

**Open `bicep/03-security-review/main.bicep`**

> "This file has eight intentional security issues. Let's see how many Copilot finds."

Select all → Copilot Chat:
```
Review this Bicep file for security concerns and missing Azure best practices.
List findings as: Severity | Issue | Recommendation
```

Walk through findings with the audience. Tick off:
- [ ] Public blob access enabled
- [ ] HTTPS not enforced (supportsHttpsTrafficOnly missing)
- [ ] Minimum TLS not set
- [ ] No blob soft delete
- [ ] NSG allow-all inbound rule
- [ ] Key Vault purge protection disabled
- [ ] Key Vault public network access open
- [ ] Output exposes a connection string (secret in plain text)

> "The last one — a connection string in an output — flows into ARM deployment history and any pipeline logs. Now ask:"

```
How should I fix the connection string output? What's the recommended pattern
for granting an application access to storage without using connection strings?
```

> "Answer: RBAC + managed identity. Copilot just taught the right pattern."

---

## Module 4: Bicep Modules (~15 min)

**Open `bicep/04-modules/main.bicep` and `bicep/04-modules/modules/storage.bicep`**

> "Bicep modules let you package reusable resource definitions. This exercise is Bicep-native — there's no Terraform equivalent in this repo. Copilot is excellent here because modules have a very regular structure."

**Step 1 — Fill the storage module:**

Open `modules/storage.bicep` → Copilot Chat:
```
Fill out this Bicep module for an Azure Storage Account.
Params: workloadName, environmentCode, locationCode, location, tags.
Derive the storage name as 'st{workloadName}{environmentCode}{locationCode}'.
Disable public access, enforce HTTPS, TLS 1.2, blob soft delete 7 days.
System-assigned identity.
Outputs: storageAccountId, storageAccountName, principalId.
```

> "Ask why it derived the name inside the module instead of accepting it as a param:"

```
Why is it better to derive the storage account name inside the module
rather than accepting it as a parameter from the caller?
```

> "Answer: the module enforces the naming convention regardless of who calls it. The caller can't accidentally pass a non-compliant name."

**Step 2 — Wire the module in main.bicep:**

```
Update main.bicep to call modules/storage.bicep twice:
once for 'app' tier storage and once for 'logs' tier storage,
using different workloadName values. Surface both module outputs.
```

**Step 3 (if time):**
```
Add a module call for modules/keyvault.bicep.
Grant the app storage account's managed identity
the Key Vault Secrets User role on the Key Vault.
Pass the principalId output from the storage module into the keyvault module.
```

> "Copilot just wired two modules together using outputs as inputs — the composition pattern at the heart of good Bicep architecture."

---

## Module 5: Azure Verified Modules (~15 min)

**Open `bicep/05-avm/main.bicep`**

> "So far we've written resource blocks and wrapped them in local modules. The next stage is Azure Verified Modules — Microsoft-published, WAF-aligned, pre-built Bicep modules from the public registry. Think of it as the module you would have written eventually, already written, tested, and Policy-reviewed."

### Part A — Discovery

In Copilot Chat (no file open):
```
What is the Azure Verified Modules registry path for a Storage Account?
What is the latest stable version available?
What are the required parameters for the minimum viable module block?
```

> "Copilot knows the AVM registry. Use it to discover module paths and params instead of browsing the docs manually."

### Part B — Compare: raw resource vs AVM

Open `bicep/03-security-review/main.bicep` alongside `bicep/05-avm/main.bicep`.

```
If I use the AVM Storage Account module instead of writing the resource block directly,
which of the 8 security issues in bicep/03-security-review/main.bicep are addressed
automatically by AVM defaults?
```

> "AVM's answer to security review: the defaults are the fix. You don't write the security controls — they're built into the module."

### Part C — Fill the module blocks

**Step 1 — Storage module block:**
```
Generate a Bicep module block that uses the AVM Storage Account module
(br/public:avm/res/storage/storage-account) to deploy a storage account with:
- Name: 'st${workloadName}${environmentCode}'
- Location and tags from params in this file
- Blob soft delete enabled (7 days)
Show the module block and required params.
```

**Step 2 — Key Vault + RBAC:**
```
Now add an AVM Key Vault module block (br/public:avm/res/key-vault/vault).
Use RBAC authorization mode.
Grant the storage account's managed identity the Key Vault Secrets User role
using the AVM module's built-in roleAssignments parameter.
```

> "Notice: RBAC grant is a parameter of the module, not a separate resource block. AVM collapses what used to be 3 resources into 1 module call."

**Step 3 — Standard AVM params:**
```
What standard parameters do ALL AVM resource modules accept?
Show me how to add a resource lock and diagnostic settings to the Key Vault module block.
```

> "Every AVM module has the same interface for lock, tags, roleAssignments, diagnosticSettings, privateEndpoints. Learn it once, use it everywhere."

### Part D — Versioning

```
How do I check for newer versions of an AVM module?
What is the recommended version pinning strategy for production?
```

> "AVM versions are semver. Pin to a version, review the changelog on upgrade — same discipline as any dependency."

---

## Module 6: Workflow and Boundaries (~10 min)

### The Review Contract

> "Let's be explicit about where Copilot sits in the workflow."

```
[Copilot] → draft Bicep resource or module
     ↓
[az bicep build]           — catch syntax errors immediately
     ↓
[az deployment what-if]    — verify intent before any change
     ↓
[PSRule for Azure]         — policy gate (CI, non-negotiable)
     ↓
[PR review]                — human judgment on design and security
     ↓
[Pipeline deploy]          — approved change applied
```

> "Copilot accelerates step one. It does not replace any downstream step. PSRule runs regardless of whether Copilot or a human wrote the line."

### High Value vs. Caution

**High Value for Bicep:**
- First draft of any resource block
- `@description()`, `@allowed()`, `@secure()` decorator generation
- Module skeleton and param wiring
- `guid()` for idempotent role assignment names
- `/explain` on inherited or unfamiliar files
- Translating ARM JSON snippets to Bicep

**Additional Caution:**
- RBAC role assignments — verify least-privilege; Copilot may suggest broad built-ins
- Network security rules — run PSRule after; `allow *` rules are a common miss
- Secret outputs — check that no sensitive value appears in an output
- `existing` references — verify the resource actually exists in the target scope

---

## Closing (2 min)

> "Three things to take back today:
> 1. Add `.github/copilot-instructions.md` to your Bicep repos — 10 minutes of setup, immediate improvement.
> 2. Use `/explain` on files your team doesn't fully understand — it's a documentation tool.
> 3. Front-load your constraints in prompts — Copilot encodes your policy as code, not as a review comment."

---

## Backup Prompts (if a demo stalls)

```
# If completions are not triggering:
"Write a Bicep resource block for an Azure Key Vault that disables public
network access and enables RBAC authorization."

# If audience wants a Terraform comparison:
"Show me the Terraform equivalent of this Bicep storage account block.
What are the three most important syntax differences?"

# If audience asks about hallucinations:
"What Bicep API version introduced the publicNetworkAccess property
on Microsoft.Storage/storageAccounts, and how would I verify this?"
# (Expected: Copilot answers; verify against learn.microsoft.com/bicep)

# If audience asks about AVM vs hand-written Bicep:
"What are the tradeoffs between using an Azure Verified Module vs writing
a Bicep resource block directly? When would you choose each approach?"
```
