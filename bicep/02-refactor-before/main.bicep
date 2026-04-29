// DEMO EXERCISE 2 — Refactor: Extract Hard-Coded Values
// ──────────────────────────────────────────────────────
// This file has multiple hard-coded values that should be params or vars.
//
// Use Copilot Chat with this three-step sequence:
//
// Step 1 — Identify:
//   "Identify all hard-coded values in this Bicep file that should be params
//    or vars. List as a table: name | current value | suggested type | description"
//
// Step 2 — Generate params:
//   "Generate param declarations for all items in that table.
//    Add @allowed() decorators where the value has a constrained set of options.
//    Add @description() to every param."
//
// Step 3 — Update references:
//   "Update the resource blocks in this file to reference the new params
//    and vars instead of the hard-coded values."
//
// Teaching points:
//   - Bicep uses @allowed() where Terraform uses validation {} blocks
//   - var is for derived/computed values; param is for caller-supplied values
//   - Ask Copilot: "Should 'location' be a param or derived from resourceGroup()?"
// ──────────────────────────────────────────────────────

// Hard-coded region — should be a param
var location = 'eastus'

// Hard-coded environment — should be a param with @allowed()
var environment = 'prod'

// Hard-coded workload name — should be a param
var workloadName = 'payments'

// Hard-coded tags — should be a param
var commonTags = {
  env: 'prod'
  owner: 'platform-team'
  'cost-center': 'cc-5678'
}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: 'rg-payments-prod-eastus'
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-payments-prod-eastus'
  location: 'eastus'
  tags: {
    env: 'prod'
    owner: 'platform-team'
    'cost-center': 'cc-5678'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    dnsServers: ['168.63.129.16']
  }
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: vnet
  name: 'snet-app'
  properties: {
    addressPrefix: '10.10.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource dataSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: vnet
  name: 'snet-data'
  properties: {
    addressPrefix: '10.10.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-app-prod-eastus'
  location: 'eastus'
  tags: {
    env: 'prod'
    owner: 'platform-team'
    'cost-center': 'cc-5678'
  }
  properties: {
    securityRules: [
      {
        name: 'allow-https-inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.0.0/8'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource nsgAssociation 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: vnet
  name: 'snet-app'
  dependsOn: [appSubnet]
  properties: {
    addressPrefix: '10.10.1.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}
