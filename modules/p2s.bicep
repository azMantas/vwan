param vpnRootCertificateName string
param publicCertData string
param vpnServerConfigName string = 'init'
param virtualHubId string
param addressPrefixes string = '10.10.10.0/24'


resource vpnServerConfigurations 'Microsoft.Network/vpnServerConfigurations@2022-05-01' = {
  name: vpnServerConfigName
  location: resourceGroup().location
  properties: {
    vpnProtocols: [
      'OpenVPN'
    ]
    vpnAuthenticationTypes:[
     'Certificate' 
    ]
    vpnClientRootCertificates:[
      {
       name: vpnRootCertificateName
       publicCertData: publicCertData
      }
    ]
  }
}

resource p2sGateway 'Microsoft.Network/p2svpnGateways@2022-05-01' = {
  name: 'init'
  location: resourceGroup().location
  properties:{
    vpnGatewayScaleUnit: 1
    isRoutingPreferenceInternet: false
    virtualHub: {
      id: virtualHubId
    }
    vpnServerConfiguration: {
      id: vpnServerConfigurations.id
    }
    p2SConnectionConfigurations:[
      {
        name: 'P2SConnectionConfigDefault'
        properties:{
          enableInternetSecurity: true
          vpnClientAddressPool: {
            addressPrefixes:[
              addressPrefixes
            ]
          }
        }
      }
    ]
  }
}
