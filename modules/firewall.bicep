param hubId string

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

output firewallResourceId string = firewall.id
