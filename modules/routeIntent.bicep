param virtualHubName string
param firewallId string

resource virtualHub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: virtualHubName
}

resource routeIntent 'Microsoft.Network/virtualHubs/routingIntent@2022-05-01' = {
  name: 'intent'
  parent: virtualHub
  properties:{
    routingPolicies:[
      {
        name: 'InternetTraffic'
        destinations: [
          'Internet'
        ]
        nextHop: firewallId
      }
      {
        name: 'PrivateTrafficPolicy'
        destinations: [
          'PrivateTraffic'
        ]
        nextHop: firewallId
      }
    ]
  }
}
