param hubId string
param laResourceId string = '/subscriptions/7e88dc1f-a45d-47dc-b986-785db0fea339/resourcegroups/logs/providers/microsoft.operationalinsights/workspaces/la-hub'

resource firewall 'Microsoft.Network/azureFirewalls@2022-05-01' = {
  name: 'azFirewall'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    virtualHub: {
      id: hubId
    }
    hubIPAddresses:{
      publicIPs:{
        count: 1
      }
    }
  }
}

resource firewalldiag 'Microsoft.Network/azureFirewalls/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${firewall.name}/Microsoft.Insights/set-by-bicep'
  location: resourceGroup().location
  properties: {
    workspaceId: laResourceId
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
    ]
  }
}

resource  firewallPolicy 'Microsoft.Network/firewallPolicies@2022-05-01' = {
  name: 'main'
  location: resourceGroup().location
  properties:{
    sku:{
      tier:'Basic'
    }
  }
}


output firewallResourceId string = firewall.id
