param hubName string
param AzureFirewallResourceId string

resource vHub 'Microsoft.Network/virtualHubs@2021-02-01' existing = {
  name: hubName
}

resource hubRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-05-01' = {
  name: 'defaultRouteTable'
  parent: vHub
  properties: {
    routes:[
      {
        name: 'allTraffic'
        destinationType: 'CIDR'
        destinations: [
          '0.0.0.0/0'
        ]
        nextHop: AzureFirewallResourceId
        nextHopType: 'ResourceId'
      }
    ]
    labels: [
      'default'
    ]
  } 
}

output resourceId string = hubRouteTable.id
