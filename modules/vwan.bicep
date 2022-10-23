


resource vwan 'Microsoft.Network/virtualWans@2022-05-01' = {
  name: 'wan'
  location: resourceGroup().location
  properties:{
    type: 'Standard'
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
  }
}

output vwanResourceId string = vwan.id
