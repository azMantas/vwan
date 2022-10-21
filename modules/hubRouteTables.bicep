param hubName string
param routeTableName string = 'Default'
param AzureFirewallResourceId string

resource vHub 'Microsoft.Network/virtualHubs@2021-02-01' existing = {
  name: hubName
}

resource hubRouteTable 'Microsoft.Network/virtualHubs/routeTables@2021-02-01' = {
  name: routeTableName
  parent: vHub
  properties: {
      routes: [
        {
          destinationType: 'CIDR'
          destinations: [
            '0.0.0.0/0'
          ]
          nextHopType: 'ResourceId'
          nextHops:[
            AzureFirewallResourceId
          ]
        }
      ]
  } 
}

output resourceId string = hubRouteTable.id
