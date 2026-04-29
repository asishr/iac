# GitHub Copilot in the IDE — Practical Tips for IaC
### Session 2 Demo Repository

A hands-on demo repository for showing GitHub Copilot techniques with **Terraform** and **Bicep** to engineering and IaC practitioner audiences.

---

## Prerequisites

| Tool | Required |
|------|----------|
| VS Code | ✅ |
| GitHub Copilot + Copilot Chat extensions | ✅ |
| HashiCorp Terraform extension | ✅ |
| Bicep extension (Microsoft) | ✅ |
| Terraform CLI ≥ 1.7 | Optional (for `validate`) |
| Azure CLI | Optional (for Bicep build) |

> **Tip for presenters:** Clone this repo and open it in VS Code before the session. All workspace settings and Copilot context are pre-configured.

---

## Repository Structure

```
copilot-iac-demo/
├── .github/
│   └── copilot-instructions.md   ← Workspace-level Copilot context (show this first!)
├── .vscode/
│   ├── settings.json
│   └── extensions.json
├── terraform/
│   ├── 00-start-here/            ← Exercise 1: Live scaffold demo
│   ├── 01-scaffold-example/      ← Completed example (what Copilot can produce)
│   ├── 02-refactor-before/       ← Exercise 2: Extract hard-coded values
│   └── 03-security-review/       ← Exercise 3: Security issues for Copilot to find
├── bicep/
│   ├── 00-start-here/            ← Exercise 1 (Bicep variant)
│   ├── 01-scaffold-example/      ← Completed Container App example
│   └── 02-explain-exercise/      ← Exercise: Explain a complex file
└── prompts/
    └── quick-reference.md        ← Prompt patterns cheat-sheet
```

---

## Demo Flow (90 min)

| Module | Time | Files |
|--------|------|-------|
| **1. Setup & context** | 10 min | `.github/copilot-instructions.md`, `.vscode/` |
| **2. Prompting patterns** | 25 min | `terraform/00-start-here/`, `terraform/01-scaffold-example/` |
| **3. Explain & learn** | 20 min | `bicep/02-explain-exercise/`, `terraform/03-security-review/` |
| **4. Workflow & boundaries** | 20 min | `terraform/03-security-review/` discussion |
| **5. Hands-on exercises** | 15 min | `terraform/02-refactor-before/`, `bicep/00-start-here/` |

See [DEMO-SCRIPT.md](DEMO-SCRIPT.md) for presenter talking points and exact prompts.

---

## Key Teaching Points

1. **Context is everything** — open related files, use `.github/copilot-instructions.md`
2. **Prompt with intent + constraints** — not just "create X" but "create X that meets Y"
3. **Break tasks into reviewable steps** — mirrors good PR practice
4. **Use `/explain` aggressively** — for learning, onboarding, and understanding legacy code
5. **Copilot accelerates; policy gates protect** — Checkov/tfsec/Azure Policy still run
6. **IAM, network rules, and secrets always get a human second look**
