targetScope = 'subscription'

param VWanSubscriptionId string = '6247f2f5-c221-464d-afd3-3ad763a9fc5e'
param hubName string = 'hub'

var landingZone = [
  {
    lzName: 'lz1'
    vnetAddressPrefix: '10.10.20.0/24'
    subnetAddressPrefix: '10.10.20.0/27'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  {
    lzName: 'lz2'
    vnetAddressPrefix: '10.10.30.0/24'
    subnetAddressPrefix: '10.10.30.0/27'
    privateEndpointNetworkPolicies: 'Enabled'
  }
  {
    lzName: 'lz3'
    vnetAddressPrefix: '10.10.40.0/24'
    subnetAddressPrefix: '10.10.40.0/27'
    privateEndpointNetworkPolicies: 'Disabled'
  }
]

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (item, lz) in landingZone: {
  name: item.lzName
  location: 'westeurope'
}]

@description('deploy vnet, keyvault and privateEndpoints. There is no DNS at the moment, use host file')
module resources 'modules/lz.bicep' = [for (item, lz) in landingZone: {
  name: '${item.lzName}-deployment'
  scope: rg[lz]
  params:{
    VWanSubscriptionId: VWanSubscriptionId
    virtualHubName: hubName
    lzName: item.lzName
    subnetAddressPrefix: item.subnetAddressPrefix 
    vnetAddressPrefix: item.vnetAddressPrefix
    privateEndpointNetworkPolicies: item.privateEndpointNetworkPolicies
  }  
}]


output outputstst array = [ for (item, lz) in landingZone: {
  kvFQDN: resources[lz].outputs.kvFQDN
  kvIp: resources[lz].outputs.kvIp
  storageFQDN: resources[lz].outputs.stageFQDN
  storageIp: resources[lz].outputs.storageIp
}]
