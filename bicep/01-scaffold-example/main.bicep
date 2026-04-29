// ─────────────────────────────────────────────────────────────────
// SCAFFOLD EXAMPLE — Container App with Dapr + AcrPull RBAC
// ─────────────────────────────────────────────────────────────────
// Prompt used to generate this file:
//
//   "Deploy an Azure Container App with:
//    - External ingress on port 8080
//    - Dapr sidecar enabled, app-id = 'orders-service'
//    - HTTP scale rule: concurrentRequests = 10, min = 1, max = 5
//    - System-assigned managed identity
//    - Grant AcrPull on param acrName to the app's managed identity
//    - Mandatory tags: env, owner, cost-center"
//
// Teaching points to highlight:
//   - guid() in role assignment name ensures idempotency
//   - AcrPull role definition ID is hard-coded — ask Copilot to explain why
//   - @secure() is not used here — why not? (no secrets in params)
// ─────────────────────────────────────────────────────────────────

@description('Name of the Container Apps managed environment.')
param environmentName string

@description('Name for the Container App.')
param appName string = 'orders-service'

@description('Container image to deploy (e.g. myregistry.azurecr.io/orders:latest).')
param containerImage string

@description('Name of the Azure Container Registry for AcrPull grant.')
param acrName string

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Mandatory resource tags: env, owner, cost-center.')
param tags object

// ── Existing resources ───────────────────────────────────────────

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: environmentName
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

// ── Container App ────────────────────────────────────────────────

resource ordersApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: environment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      dapr: {
        enabled: true
        appId: 'orders-service'
        appPort: 8080
        appProtocol: 'http'
      }
    }
    template: {
      containers: [
        {
          name: appName
          image: containerImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
        rules: [
          {
            name: 'http-scale'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// ── RBAC: AcrPull for the Container App's managed identity ───────
// Ask Copilot: "What does guid() do here, and what happens if I deploy twice?"

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, ordersApp.id, 'AcrPull')
  scope: acr
  properties: {
    // AcrPull built-in role definition ID
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    )
    principalId: ordersApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ── Outputs ──────────────────────────────────────────────────────

@description('Fully-qualified domain name of the deployed Container App.')
output appFqdn string = ordersApp.properties.configuration.ingress.fqdn

@description('Principal ID of the Container App system-assigned managed identity.')
output principalId string = ordersApp.identity.principalId
