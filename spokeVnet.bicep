targetScope = 'subscription'

resource vnetRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'spoke1'
  location: 'westeurope'
}

module vnet 'modules/vnet.bicep' = {
  scope: vnetRg
  name: 'spoke-1'
  params: {
    vnetAddressPrefix: '10.20.20.0/24'
    vnetName: 'spoke1'
  }
}

