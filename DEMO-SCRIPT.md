# DEMO SCRIPT — Session 2: GitHub Copilot in the IDE for IaC
### Presenter Guide

---

## Before You Start

- Clone repo, open in VS Code
- Ensure Copilot Chat panel is visible (Ctrl+Alt+I)
- Have a second monitor or window for showing Copilot Chat
- Open these files in tabs before presenting:
  - `.github/copilot-instructions.md`
  - `terraform/00-start-here/main.tf`
  - `terraform/01-scaffold-example/main.tf`
  - `bicep/02-explain-exercise/main.bicep`
  - `terraform/03-security-review/main.tf`

---

## Module 1: Setting Up for Success (~10 min)

### Talking Points

> "Before Copilot writes a single line, the context it has determines the quality of what it produces. Let me show you three things that make an immediate difference."

**Step 1 — Show `.github/copilot-instructions.md`**

Open the file. Walk through each section:
- Landing zone constraints encoded as text
- Naming conventions
- Tag requirements

> "This file is loaded into Copilot's context automatically for every chat interaction in this workspace. Think of it as a standing brief to your pair-programmer. It means you don't have to repeat 'no public endpoints' in every prompt — it's already there."

**Step 2 — Show `.vscode/extensions.json`**

> "When a teammate clones this repo and opens it in VS Code, they'll be prompted to install the recommended extensions. The Terraform and Bicep extensions give Copilot richer language understanding — syntax validation, go-to-definition, hover docs. All of this becomes additional context."

**Step 3 — Open related files side by side**

Open `terraform/01-scaffold-example/main.tf` and `terraform/01-scaffold-example/variables.tf` side by side.

> "Copilot sees everything in your open editor tabs. If `variables.tf` is open when you're editing `main.tf`, Copilot knows your variable names, types, and validation rules. Open the files you want it to reason about."

---

## Module 2: Prompting Patterns (~25 min)

### Pattern 1 — Scaffold from Intent

**Open `terraform/00-start-here/main.tf`**

> "This is the blank canvas. The comment block at the top describes what we want to build. Watch what happens when I start typing the resource declaration."

Type slowly:
```
resource "azurerm_storage_account" "diag" {
```

Accept completions one by one. After the block is complete:

> "It got most of the required arguments. But notice — did it set `public_network_access_enabled = false`? Did it set `min_tls_version`? This is the review step. Copilot gives you a fast first draft; you own the correctness."

**Switch to `terraform/01-scaffold-example/main.tf`**

> "Here's the same resource generated from a more structured prompt — notice the comment at the top of the file shows the exact prompt used. The prompt included explicit constraints, and the output reflects them. The quality of the output is a direct function of the quality of the prompt."

---

### Pattern 2 — Iterative Refactoring

**Open `terraform/02-refactor-before/main.tf`**

> "Real-world IaC files have hard-coded values everywhere. Here's a typical example. I'm going to use Copilot Chat in three steps — each step produces a reviewable output before we move to the next."

**Step 1 — in Copilot Chat:**
```
Identify all hard-coded values in this file that should be variables.
List them as a table: name | current value | suggested type | description
```

Wait for response. Show the table to audience.

> "Before we generate a single line of code, we agree on what needs to change. This is the design step."

**Step 2:**
```
Generate the variable declarations for all items in that table.
Use validation blocks where the value has a constrained set of options.
```

> "Notice the validation blocks — Copilot added them because the comment context told it this is a regulated landing zone. It's using the workspace instructions."

**Step 3:**
```
Now update the resource blocks in the file to reference these new variables
instead of the hard-coded values.
```

> "Three prompts, three reviewable outputs. At no point did we apply a change we hadn't seen. This mirrors the PR review discipline we already practice."

---

### Pattern 3 — Policy-Aware Generation

> "One more prompting technique that saves significant review time."

In Copilot Chat, paste:
```
Context: This module deploys into a regulated Azure landing zone.
Constraints:
  - All resources must have tags: env, owner, cost-center
  - No public endpoints on any resource
  - Encryption at rest required on all storage
  - Minimum TLS 1.2

Generate a Terraform module for an Azure Key Vault that meets all of these constraints.
```

> "When you front-load the constraints, Copilot encodes your policy as code rather than leaving compliance as a post-review step. You still review — but you're validating, not discovering."

---

## Module 3: Explain and Learn (~20 min)

### Demo 1 — Explain a Complex File

**Open `bicep/02-explain-exercise/main.bicep`**

Select the entire file content → Copilot Chat → type:
```
/explain
```

> "This is my favourite use of Copilot for existing codebases. It's a knowledge extraction tool. Every team has files that only one person truly understands. Copilot can give everyone a starting point."

After the explanation, ask:
```
What does the dependsOn on the 'secret' resource do, and is it actually needed
given Bicep's implicit dependency resolution?
```

> "That's a question a senior engineer would ask in a PR review. Copilot's answer here is: you're right, it's redundant because the parent relationship already implies the dependency — but it's explicit documentation of intent. This is the kind of nuanced discussion Copilot can accelerate."

Then ask:
```
What is the purpose of the guid() function in the role assignment resource name,
and what happens if I deploy this twice to the same scope?
```

> "Idempotency — a concept every IaC practitioner needs to understand. Copilot just became your teaching tool for onboarding new team members."

---

### Demo 2 — Security Review

**Open `terraform/03-security-review/main.tf`**

> "This file has a number of intentional security issues. Let's see how many Copilot can find."

Select all → Copilot Chat:
```
Review this Terraform file for security concerns and missing Azure best practices.
List findings as: Severity | Issue | Recommendation
```

Walk through the findings with the audience. Tick off which ones it caught:
- [ ] Public blob access enabled
- [ ] HTTPS not enforced
- [ ] No soft delete
- [ ] Overly permissive NSG rule (allow-all inbound)
- [ ] Key Vault purge protection disabled
- [ ] No network ACLs on Key Vault
- [ ] Sensitive output not marked `sensitive = true`
- [ ] Storage account name hard-coded (not parameterised)

> "It found most of them. Note what it might miss — this is not a replacement for Checkov or tfsec. Those tools run in your pipeline on every commit, regardless of how the code was authored. Copilot is your first-pass reviewer; static analysis is your gate."

---

## Module 4: Workflow and Boundaries (~20 min)

### The Review Contract — Discussion Slide

> "Let's talk about where Copilot adds the most value versus where you need to be careful."

Draw or show this on screen:

```
[Copilot] → draft resource
     ↓
[terraform validate / bicep build] — catch syntax errors
     ↓
[terraform plan / az deployment what-if] — verify intent
     ↓
[Checkov / tfsec / PSRule] — policy gate (non-negotiable)
     ↓
[PR review] — human judgment on design and security
     ↓
[Pipeline apply] — approved change deployed
```

> "Copilot accelerates step one. It does not replace any downstream step. This is the conversation to have with your team before you adopt it."

### High Value / Use Caution Table — Discussion

Walk through this with the audience and ask for their additions:

**High Value:**
- First draft of a resource block
- Variable and output boilerplate
- Module skeleton scaffolding
- Inline documentation (`description` fields)
- Translating between DSLs (ARM → Bicep, TF → Pulumi concepts)
- Understanding unfamiliar or legacy code
- Writing test scaffolding (Terratest, Pester, Checkov custom rules)

**Additional Caution:**
- IAM/RBAC assignments — may suggest overly broad roles
- Network security rules — may generate permissive rules
- Secret handling — never output secrets, always use `sensitive = true`
- `lifecycle` blocks — `prevent_destroy` / `ignore_changes` can mask drift
- Provider version pinning — always review constraint operators

---

## Module 5: Hands-On Exercises (~15 min)

### Exercise 1 — Scaffold (8 min)

> "Open `terraform/00-start-here/main.tf` or `bicep/00-start-here/main.bicep`. The comment at the top describes what to build. Use Copilot to generate it, then use Chat to review it. Don't accept the first output uncritically."

Circulate and observe. Common teaching moments:
- Did Copilot miss `public_network_access_enabled = false`? Point it out.
- Did it suggest a hard-coded name? Ask how to fix that.

### Exercise 2 — Explain and Improve (7 min)

> "Open `bicep/02-explain-exercise/main.bicep`. Ask Copilot: 'Review this file for security concerns.' Pick one suggestion and ask it to implement the fix. Then look at the diff — would you accept this in a PR? Why or why not?"

---

## Closing (2 min)

> "Three things to take back to your team today:
> 1. Add a `.github/copilot-instructions.md` to your IaC repos — it takes 10 minutes and immediately improves suggestion quality.
> 2. Use `/explain` on files your team doesn't fully understand — it's a documentation tool.
> 3. Keep your policy gates in the pipeline. Copilot is the accelerator; the gates are the guardrails."

---

## Backup Prompts (if demos stall)

```
# If inline completions aren't triggering:
"Write a Terraform azurerm_storage_account resource that disables public access
and enables soft delete."

# If audience wants a live translate demo:
"Convert this Terraform storage account resource to its Bicep equivalent.
Highlight the three most important syntax differences."

# If audience asks about hallucinations:
"What Terraform provider version introduced the public_network_access_enabled
argument for azurerm_storage_account, and how would I verify this?"
# (Expected: Copilot will answer; always verify against registry.terraform.io)
```
