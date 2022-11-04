targetScope = 'subscription'

resource wanRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'vwan'
  location: 'westeurope'
}


module vwan 'modules/vwan.bicep' = {
  scope: wanRG
  name: 'wan-deployment'
}

module hubs 'modules/shub.bicep' = {
  scope: wanRG
  name: 'hub-deployment'
  params: {
    virtualWanId: vwan.outputs.vwanResourceId
  }
}

module firewall 'modules/firewall.bicep' = {
  scope: wanRG
  name: 'firewall-deployment'
  params: {
    hubId: hubs.outputs.hubResourceId
  }
}

module routeTables 'modules/hubRouteTables.bicep' = {
  scope: wanRG
  name: 'hub-route-tables-deployment'
  params: {
    AzureFirewallResourceId: firewall.outputs.firewallResourceId 
    hubName: hubs.outputs.hubName
  }
}

resource existingKv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'wanSecrets'
  scope: resourceGroup('secrets')
}


module vpnConfig 'modules/p2s.bicep' = {
  scope: wanRG
  name: 'vpnConfig-deployment'
  params: {
    vpnRootCertificateName: 'vpnCertTst'
    publicCertData: existingKv.getSecret('p2s')
    virtualHubId: hubs.outputs.hubResourceId
  }
}
