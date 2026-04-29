// DEMO EXERCISE 1 — Scaffold a Container App with Copilot
// ─────────────────────────────────────────────────────────
// Using Copilot, generate an Azure Container App that:
//   - References an existing Container Apps environment (param: environmentName)
//   - Deploys a container image from ACR (params: containerImage, acrName)
//   - External ingress on port 8080
//   - System-assigned managed identity with AcrPull granted on the ACR
//   - HTTP scale rule: concurrentRequests = 10, min = 1, max = 5
//   - Mandatory tags: env, owner, cost-center
//
// Steps:
//   1. Start typing the resource declaration below — accept Copilot completions
//   2. Ask Copilot Chat: "Review this Container App for security concerns"
//   3. Ask Copilot Chat: "What RBAC role grants AcrPull and how do I assign it?"
//   4. Run: az bicep build --file main.bicep
//
// Tip: The .github/copilot-instructions.md in this repo gives Copilot
// the landing zone constraints automatically.
// ─────────────────────────────────────────────────────────

@description('Name of the existing Container Apps managed environment.')
param environmentName string

@description('Container image to deploy (e.g. myregistry.azurecr.io/app:latest).')
param containerImage string

@description('Name of the Azure Container Registry for AcrPull grant.')
param acrName string

param location string = resourceGroup().location

@description('Mandatory resource tags: env, owner, cost-center.')
param tags object

// TODO: Add existing resource references for the environment and ACR

// TODO: Start typing below and let Copilot complete the Container App resource
// resource app 'Microsoft.App/containerApps@2024-03-01' = {
