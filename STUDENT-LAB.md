# Student Lab Guide
## Session 2: GitHub Copilot in the IDE — Practical Tips for IaC

Work through the exercises below at your own pace. Each builds on the one before it.
Everything you need is already in this repository.

---

## Prerequisites

Before starting, confirm you have:

- [ ] VS Code installed
- [ ] **Bicep extension** installed (`ms-azuretools.vscode-bicep`)
- [ ] **GitHub Copilot** and **GitHub Copilot Chat** extensions installed and signed in
- [ ] Azure CLI installed (`az --version` returns a version number)
- [ ] This repository cloned and open in VS Code

> **Tip:** When you open this repo in VS Code, you will be prompted to install recommended extensions automatically. Accept the prompt.

---

## How to Use Copilot Chat

- Open the Chat panel: `Ctrl+Alt+I` (Windows/Linux) or `Cmd+Alt+I` (Mac)
- To run a slash command on selected code: select the code first, then type the command in Chat
- Inline completions appear as you type — press `Tab` to accept, `Esc` to dismiss

---

## Exercise 1 — Scaffold a Resource from a Prompt

**File:** `bicep/00-start-here/main.bicep`

**Goal:** Use Copilot to generate a Container App resource from a structured comment prompt.

### Steps

1. Open `bicep/00-start-here/main.bicep`.

2. Read the comment block at the top. It describes exactly what the resource should do.

3. At the bottom of the file, start typing the resource declaration:
   ```bicep
   resource ordersApp 'Microsoft.App/containerApps@2024-03-01' = {
   ```

4. Press `Enter` after the opening brace. Wait for Copilot to suggest the next line. Accept completions with `Tab` until the block is complete.

5. Compare your output to `bicep/01-scaffold-example/main.bicep` — the completed reference version. Notice:
   - Does your version have `identity: { type: 'SystemAssigned' }`?
   - Does it have `scale` rules?
   - Does it have an `ingressConfig` block?

6. In Copilot Chat, ask:
   ```
   Review this Container App resource for security concerns.
   List any missing best practices.
   ```

7. Ask a follow-up:
   ```
   What RBAC role grants AcrPull permission to a Container App,
   and how do I write the role assignment in Bicep?
   ```

8. Build the file to check for syntax errors:
   ```
   az bicep build --file main.bicep
   ```

**What to notice:** The `.github/copilot-instructions.md` in this repo gives Copilot your landing zone constraints automatically — you don't need to repeat them in every prompt.

---

## Exercise 2 — Understand Existing Code with /explain

**File:** `bicep/02-explain-exercise/main.bicep`

**Goal:** Use Copilot as a "why" engine to understand patterns in an unfamiliar file.

### Steps

1. Open `bicep/02-explain-exercise/main.bicep`.

2. Select the entire file contents (`Ctrl+A`), then in Copilot Chat type:
   ```
   /explain
   ```
   Read the summary. Does it match your initial reading of the file?

3. Now ask targeted questions. Copy each prompt into Copilot Chat:

   **Prompt A:**
   ```
   Explain the @secure() decorator on bootstrapSecret.
   What happens to the value in deployment logs without it?
   ```

   **Prompt B:**
   ```
   What does the dependsOn on the 'bootstrapKvSecret' resource do?
   Is it actually needed given Bicep's implicit dependency resolution?
   ```

   **Prompt C:**
   ```
   What is the purpose of guid() in the role assignment resource name?
   What would happen if I used a static string like 'role-assignment' instead?
   ```

   **Prompt D:**
   ```
   I'm new to Bicep. What is the difference between a param and a var in this file,
   and how do I decide which one to use?
   ```

4. Find the `var` block near the top of the file. Ask:
   ```
   Why are the resource names derived using var rather than passed as params?
   What are the tradeoffs?
   ```

**Reflection:** Which answer surprised you the most? The `@secure()` answer has a real-world production implication — keep it in mind when you write outputs.

---

## Exercise 3 — Refactor: Remove Hard-Coded Values

**File:** `bicep/02-refactor-before/main.bicep`

**Goal:** Use a structured 3-step prompt sequence to extract hard-coded values into params and vars.

### Steps

1. Open `bicep/02-refactor-before/main.bicep`. Scroll through it — notice the hard-coded location, environment name, tags, and names repeated inside every resource block.

2. In Copilot Chat, run **Step 1**:
   ```
   Identify all hard-coded values in this Bicep file that should be params or vars.
   List as a table: name | current value | suggested type (param/var) | description
   ```
   Review the table. Do you agree with every row? Would you add anything?

3. Run **Step 2**:
   ```
   Generate param declarations for all items marked 'param' in that table.
   Add @allowed() decorators where the value has a constrained set of options.
   Add @description() to every param.
   ```
   Copy the generated param declarations to the top of the file (above the resource blocks).

4. Run **Step 3**:
   ```
   Update the resource blocks in this file to reference the new params and vars
   instead of the hard-coded values. Use var for any values derived from params.
   ```
   Apply the suggested changes.

5. Build to verify there are no errors:
   ```
   az bicep build --file main.bicep
   ```

6. Ask a comparison question:
   ```
   In Terraform, how would I enforce allowed values on a string variable?
   How does that compare to Bicep's @allowed() decorator?
   ```

**What to notice:** `var` is for values computed from other values. `param` is for values the caller provides. Copilot should have used `var` for derived resource names and `param` for anything the deployer needs to supply.

---

## Exercise 4 — Security Review

**File:** `bicep/03-security-review/main.bicep`

**Goal:** Find security issues in a file using Copilot, then learn how to fix them.

### Steps

1. Open `bicep/03-security-review/main.bicep`. Do a quick read — can you spot any issues before asking Copilot?

2. Select all (`Ctrl+A`), then in Copilot Chat:
   ```
   Review this Bicep file for security concerns and missing Azure best practices.
   List findings as: Severity | Issue | Recommendation
   ```

3. Using the findings table below, tick off what Copilot identified. How many did it catch?

   | # | Issue | Caught? |
   |---|-------|---------|
   | 1 | Storage: public blob access allowed | ☐ |
   | 2 | Storage: HTTPS not enforced | ☐ |
   | 3 | Storage: minimum TLS not configured | ☐ |
   | 4 | Storage: no blob soft delete | ☐ |
   | 5 | NSG: allow-all inbound wildcard rule | ☐ |
   | 6 | Key Vault: purge protection disabled | ☐ |
   | 7 | Key Vault: public network access open | ☐ |
   | 8 | Output: connection string exposed in plain text | ☐ |

4. For any issue Copilot caught, ask it to fix one of them:
   ```
   Fix the storage account in this file to enforce HTTPS and set minimum TLS to 1.2.
   Show only the changed lines.
   ```

5. Ask about the output issue specifically:
   ```
   How should I fix the connection string output?
   What is the recommended pattern for giving an application access to storage
   without using connection strings at all?
   ```

6. Ask about the pipeline:
   ```
   Which of these findings would PSRule for Azure catch automatically in a CI pipeline?
   ```

**Key takeaway:** Copilot is a fast first-pass reviewer. PSRule for Azure and Azure Policy are your mandatory pipeline gates — they run regardless of how the code was written.

---

## Exercise 5 — Bicep Modules

**Files:** `bicep/04-modules/main.bicep`, `bicep/04-modules/modules/storage.bicep`, `bicep/04-modules/modules/keyvault.bicep`

**Goal:** Use Copilot to fill in reusable Bicep modules and wire them together in a parent template.

### Steps

1. Open `bicep/04-modules/modules/storage.bicep`. Read the existing param declarations and the TODO comment.

2. In Copilot Chat, with the storage module file active:
   ```
   Fill out this Bicep module for an Azure Storage Account.
   Params already declared: workloadName, environmentCode, locationCode, location, tags.
   Derive the storage account name as 'st{workloadName}{environmentCode}{locationCode}' using a var.
   Requirements: disable public access, enforce HTTPS, set TLS 1.2, enable blob soft delete for 7 days,
   system-assigned managed identity.
   Outputs needed: storageAccountId, storageAccountName, principalId.
   ```
   Apply the generated code.

3. Ask a design question:
   ```
   Why is it better to derive the storage account name inside the module
   rather than accepting it as a parameter from the caller?
   ```

4. Open `bicep/04-modules/main.bicep`. Ask Copilot Chat:
   ```
   Update this main.bicep to call modules/storage.bicep twice:
   once for 'app' tier storage (workloadName = 'orders') and
   once for 'logs' tier storage (workloadName = 'logs').
   Use different module instance names. Surface both modules' storageAccountName outputs.
   ```

5. Open `bicep/04-modules/modules/keyvault.bicep`. Fill it in with a similar prompt, then wire it into `main.bicep`:
   ```
   Add a module call for modules/keyvault.bicep in main.bicep.
   Grant the 'orders' storage account's managed identity the Key Vault Secrets User role
   on the Key Vault. Use the principalId output from the storage module as the input.
   ```

6. Build the parent template:
   ```
   az bicep build --file main.bicep
   ```

**What to notice:** The `principalId` output of one module becomes an input to another module. This is output-to-input wiring — the core composition pattern for Bicep.

---

## Bonus — Copilot Workspace Context

**File:** `.github/copilot-instructions.md`

Open this file and read through it. Then try these prompts in Chat (no file needs to be open):

```
Generate a Bicep resource block for an Azure Key Vault that complies with
the constraints defined in our workspace instructions.
```

Notice that Copilot uses the naming convention, tags, and network posture from the instructions file without you having to repeat them. Now try:

```
Does this file configure any constraints about RBAC vs Key Vault access policies?
What is the rule?
```

---

## Reference — Prompt Patterns Cheat Sheet

Open `prompts/quick-reference.md` for a one-page summary of the prompt templates used in all exercises above. Keep it open alongside your work files.

---

## Validation Checklist

Before you finish, confirm you have tried each of these at least once:

- [ ] Accepted an inline Copilot completion with `Tab`
- [ ] Used `/explain` on a selected block of code
- [ ] Used a multi-sentence Chat prompt with explicit constraints
- [ ] Used the 3-step refactor sequence (identify → generate params → update references)
- [ ] Run a security review prompt and reviewed the findings table
- [ ] Created or filled a Bicep module and consumed it from a parent template
- [ ] Run `az bicep build` to validate a file

---

## Common Issues

| Problem | Fix |
|---------|-----|
| Copilot completions not appearing | Check you are signed in: `Accounts` icon in the VS Code status bar |
| `az bicep build` not found | Run `az bicep install` first |
| Suggestions seem generic / ignore constraints | Open `.github/copilot-instructions.md` in an editor tab — it needs to be loaded |
| Module path not resolving | Ensure the file path in the `module` declaration matches the actual file location |
