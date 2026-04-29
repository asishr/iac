# GitHub Copilot in the IDE — Practical Tips for IaC
### Session 2 Demo Repository · Bicep Focus

A hands-on demo repository for showing GitHub Copilot techniques with **Azure Bicep** to engineering and IaC practitioner audiences. Terraform examples are included as reference/comparison only.

---

## Prerequisites

| Tool | Required |
|------|----------|
| VS Code | ✅ |
| GitHub Copilot + Copilot Chat extensions | ✅ |
| Bicep extension (Microsoft) | ✅ |
| Azure CLI (for `az bicep build` and `az deployment what-if`) | ✅ |
| HashiCorp Terraform extension | Optional (reference only) |

> **Tip for presenters:** Clone this repo and open it in VS Code before the session. All workspace settings and Copilot context are pre-configured.

---

## Repository Structure

```
copilot-iac-demo/
├── .github/
│   └── copilot-instructions.md     ← Workspace-level Copilot context (show this first!)
├── .vscode/
│   ├── settings.json
│   └── extensions.json
├── bicep/                          ← PRIMARY demo content
│   ├── 00-start-here/              ← Exercise 1: Live scaffold demo
│   ├── 01-scaffold-example/        ← Completed Container App + AcrPull RBAC
│   ├── 02-explain-exercise/        ← Exercise 2: Explain a complex Key Vault file
│   ├── 02-refactor-before/         ← Exercise 3: Extract hard-coded values
│   ├── 03-security-review/         ← Exercise 4: Find 8 security issues
│   └── 04-modules/                 ← Exercise 5: Build reusable Bicep modules
│       └── modules/
│           ├── storage.bicep       ← Placeholder — Copilot fills it in live
│           └── keyvault.bicep      ← Placeholder — Copilot fills it in live
├── terraform/                      ← Reference / comparison content only
│   ├── 01-scaffold-example/
│   ├── 02-refactor-before/
│   └── 03-security-review/
└── prompts/
    └── quick-reference.md          ← Bicep-first prompt cheat-sheet
```

---

## Demo Flow (90 min)

| Module | Time | Files |
|--------|------|-------|
| **1. Setup & context** | 10 min | `.github/copilot-instructions.md`, `.vscode/` |
| **2. Scaffold from intent** | 20 min | `bicep/00-start-here/`, `bicep/01-scaffold-example/` |
| **3. Explain & learn** | 15 min | `bicep/02-explain-exercise/` |
| **4. Refactor & security review** | 20 min | `bicep/02-refactor-before/`, `bicep/03-security-review/` |
| **5. Bicep modules** | 15 min | `bicep/04-modules/` |
| **6. Workflow & boundaries** | 10 min | Discussion + pipeline diagram |

See [DEMO-SCRIPT.md](DEMO-SCRIPT.md) for presenter talking points and exact prompts.

---

## Key Teaching Points

1. **Context is everything** — open related files, use `.github/copilot-instructions.md`
2. **Prompt with intent + constraints** — not just "create X" but "create X that meets Y"
3. **Break tasks into reviewable steps** — mirrors good PR practice
4. **Use `/explain` aggressively** — for learning, onboarding, and understanding legacy code
5. **Bicep modules = reuse and guardrails** — modules let teams encode policy as code
6. **Copilot accelerates; PSRule/Azure Policy protect** — keep gates in the pipeline
7. **IAM, network rules, and secrets always get a human second look**

---

## Bicep-Specific Copilot Strengths

| Bicep Pattern | What Copilot helps with |
|---|---|
| `@description()` / `@allowed()` / `@secure()` decorators | Generating all decorator blocks from intent |
| `existing` keyword | Referencing pre-existing resources correctly |
| `guid()` in role assignments | Idempotent naming — Copilot explains the why |
| Module param wiring | Connecting outputs from one module to params of another |
| `az deployment what-if` | Generating the right CLI command for the template |
| `dependsOn` vs implicit deps | Copilot explains when explicit deps are and aren't needed |
