param hubId string
param laResourceId string

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

resource  firewallPolicy 'Microsoft.Network/firewallPolicies@2022-05-01' = {
  name: 'main'
  location: resourceGroup().location
  properties:{
    sku:{
      tier:'Standard'
    }
  }
}

resource firewallRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  name: 'DefaultApplicationRuleCollectionGroup'
  parent: firewallPolicy
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'whitelistedResources'
        priority: 100
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'p2s-lz1'
            protocols: [
              {
                port: 443
                protocolType:'Https'
              }
            ]
            sourceAddresses:[
              '10.10.10.0/24'
            ]
            targetFqdns:[
              '*.vault.azure.net'
              '*.blob.core.windows.net'
            ]
          }
        ]
      }
      ]
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

output firewallResourceId string = firewall.id
