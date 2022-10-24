targetScope = 'subscription'

resource vnetRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'lz1'  
  location: 'westeurope'
}

module vnet 'modules/vnet.bicep' = {
  scope: vnetRg
  name: 'spoke-1'
  params: {
    vnetAddressPrefix: '10.20.20.0/24'
    vnetName: 'lz1'
    subnetName: 'mainSubnet'
    subnetAddressPrefix: '10.20.20.0/27'
  }
}

