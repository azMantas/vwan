param lzName string
param vnetAddressPrefix string
param subnetAddressPrefix string
param virtualHubName string
param VWanSubscriptionId string
@allowed([
    'Enabled'
    'Disabled'
    'RouteTableEnabled'
    'NetworkSecurityGroupEnabled'
  ]
)
param privateEndpointNetworkPolicies string
param blobPrivateDnsZoneId string
param vaultPrivateDnsZoneId string

var unique = take(uniqueString(lzName), 5)
var vnetName = 'vnet-${lzName}'
var subnetName = 'snet-pe-${lzName}'
var kvName = 'kvv2-${lzName}-${unique}'
var stName = 'st${lzName}${unique}'

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
        name: 'snet-pe-${lzName}'
        properties: {
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
        }
      }
    ]
  }
  resource peSubnet 'subnets' existing = {
    name: subnetName
  }
}

module peering 'hubVirtualNetworkConnections.bicep' = {
  name: 'peer-${vnetName}-deployment'
  scope: resourceGroup(VWanSubscriptionId, 'vwan')
  params: {
    associatedRouteTable: '/subscriptions/${VWanSubscriptionId}/resourceGroups/vwan/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/defaultRouteTable'
    propagatedRouteTables: '/subscriptions/${VWanSubscriptionId}/resourceGroups/vwan/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/noneRouteTable'
    remoteVnetid: vnet.id
    virtualConnectionName: vnetName
    virtualHubName: virtualHubName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: false
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

resource kvPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'pe-${kvName}'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: vnet::peSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-${kvName}'
        properties: {

          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'nic-${kvName}'
  }
}

resource keyvaultPrivateDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: 'vault'
  parent: kvPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vault'
        properties: {
          privateDnsZoneId: vaultPrivateDnsZoneId
        }
      }
    ]
  }
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: stName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    supportsHttpsTrafficOnly: true
    allowCrossTenantReplication: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource stPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: 'pe-${stName}'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: vnet::peSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-${stName}'
        properties: {

          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'nic-${stName}'
  }
}

resource storagePrivateDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: 'blob'
  parent: stPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob'
        properties: {
          privateDnsZoneId: blobPrivateDnsZoneId
        }
      }
    ]
  }
}
