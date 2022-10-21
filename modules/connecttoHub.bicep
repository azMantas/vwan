param remoteVnetid string
param virtualConnectionName string
param associatedRouteTable string 
param propagatedRouteTables string
param virtualHubName string

resource virtualHub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: virtualHubName
}

resource vnetConnections 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-05-01' = {
  name: virtualConnectionName
  parent: virtualHub
  properties:{
    remoteVirtualNetwork:  {
      id: remoteVnetid
    }
    enableInternetSecurity: true
    routingConfiguration: {
      associatedRouteTable:{
        id: associatedRouteTable
      }
      propagatedRouteTables:{
       ids:[
         {
           id: propagatedRouteTables
         }
       ]
       labels:[
         'none'
       ] 
      }
    }
  }
}
