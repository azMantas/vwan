param hubName string
param hubAddressPrefix string = '10.20.30.0/24'
param virtualWanId string

resource hub 'Microsoft.Network/virtualHubs@2022-05-01' = {
  name: hubName
  location: resourceGroup().location
  properties:{
    sku: 'Standard'
    addressPrefix: hubAddressPrefix
    virtualWan: {
      id: virtualWanId
    }
    allowBranchToBranchTraffic: false
  }
}

output hubResourceId string = hub.id
output hubName string = hub.name
