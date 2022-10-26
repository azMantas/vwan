param parentResourceName string = 'main'

resource firewallPolicies 'Microsoft.Network/firewallPolicies@2022-01-01' existing = {
  name: parentResourceName
}

resource networkRuleCollectionGroupResource 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  name: 'DefaultApplicationRuleCollectionGroup'
  parent:  firewallPolicies
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
