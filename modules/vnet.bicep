
param virtualHubName string = 'hubv2'
param vnetName string 
param vnetAddressPrefix string
param subnetName string
param subnetAddressPrefix string



resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: resourceGroup().location
  properties:{
    addressSpace: {
      addressPrefixes:[
        vnetAddressPrefix
      ]
    }
    dhcpOptions:{
      dnsServers:[
        '10.20.30.132'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties:{
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
  resource mainSubnet 'subnets' existing = {
    name: subnetName
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

output subnetId string = vnet::mainSubnet.id
