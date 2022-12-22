param vnetName string = 'vnet-dns'
param vnetAddressPrefix string = '10.20.20.0/24'
param indboundSubnetName string = 'snet-indbound'
param indoboundSubnetAddressPrefix string = '10.20.20.0/27'
param outboundSubnetName string = 'snet-outound'
param oboundSubnetAddressPrefix string = '10.20.20.32/27'
param virtualHubName string = 'hub'
param subscriptionid string = '6247f2f5-c221-464d-afd3-3ad763a9fc5e'
param privateDnsZone array = [
  'privatelink.blob.core.windows.net'
  'privatelink.vaultcore.azure.net'
]



resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: indboundSubnetName
        properties: {
          addressPrefix: indoboundSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: outboundSubnetName
        properties: {
          addressPrefix: oboundSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
    ]
  }
  resource indbound 'subnets' existing = {
    name: indboundSubnetName
  }
  resource outbound 'subnets' existing = {
    name: outboundSubnetName
  }
}

resource dnsResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: 'dns'
  location: resourceGroup().location
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
  resource inboundEndpoints 'inboundEndpoints@2022-07-01' = {
    name: 'indbound'
    location: resourceGroup().location
    properties: {
      ipConfigurations: [
        {
          privateIpAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet::indbound.id
          }
        }
      ]
    }
  }
}

module peering 'hubVirtualNetworkConnections.bicep' = {
  name: 'peer-${vnetName}-deployment'
  scope: resourceGroup(subscriptionid, 'vwan')
  params: {
    associatedRouteTable: '/subscriptions/${subscriptionid}/resourceGroups/vwan/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/defaultRouteTable'
    propagatedRouteTables: '/subscriptions/${subscriptionid}/resourceGroups/vwan/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/noneRouteTable'
    remoteVnetid: vnet.id
    virtualConnectionName: vnetName
    virtualHubName: virtualHubName
  }
}



resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = [for (zone, index) in privateDnsZone: {
  name: zone
  location: 'global'
  properties:{
  }
}]

resource links 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (item, index) in privateDnsZone: {
  name: item
  parent: privateDns[index]
  location: 'global'
  properties:{
    registrationEnabled: false
    virtualNetwork:{
      id: vnet.id
    }
  }
}]

output indboundIpAdr string = dnsResolver::inboundEndpoints.properties.ipConfigurations[0].privateIpAddress
