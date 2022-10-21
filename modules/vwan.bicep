


resource vwan 'Microsoft.Network/virtualWans@2022-05-01' = {
  name: 'wan'
  location: resourceGroup().location
  properties:{
    type: 'Standard'
    disableVpnEncryption: true
    allowBranchToBranchTraffic: false
    allowVnetToVnetTraffic: true
  }
}

output vwanResourceId string = vwan.id
