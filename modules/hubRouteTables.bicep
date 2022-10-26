param hubName string
param AzureFirewallResourceId string

resource vHub 'Microsoft.Network/virtualHubs@2021-02-01' existing = {
  name: hubName
}

resource hubRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-05-01' = {
  name: 'defaultRouteTable'
  parent: vHub
  properties: {
    routes: [
      {
        name: 'all_traffic'
        destinationType: 'CIDR'
        destinations: [
          '0.0.0.0/0'
          '10.0.0.0/8'
          '172.16.0.0/12'
          '192.168.0.0/16'
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
