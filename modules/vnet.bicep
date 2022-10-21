
param vnetName string 
param vnetAddressPrefix string
param virtualHubName string = 'hubv2'




resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes:[
        vnetAddressPrefix
      ]
    }
  }
}

module peering 'connecttoHub.bicep' = {
  name: 'peer'
  scope: resourceGroup('7e88dc1f-a45d-47dc-b986-785db0fea339','vwan')
  params: {
    associatedRouteTable: '/subscriptions/7e88dc1f-a45d-47dc-b986-785db0fea339/resourceGroups/vwan/providers/Microsoft.Network/virtualHubs/hubv2/hubRouteTables/defaultRouteTable'
    propagatedRouteTables: '/subscriptions/7e88dc1f-a45d-47dc-b986-785db0fea339/resourceGroups/vwan/providers/Microsoft.Network/virtualHubs/hubv2/hubRouteTables/noneRouteTable'
    remoteVnetid: vnet.id
    virtualConnectionName: vnetName
    virtualHubName: virtualHubName
  }
}
