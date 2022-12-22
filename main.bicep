targetScope = 'subscription'

param hubName string = 'hub'
param p2SPublicCertData string = 'MIIDLjCCAhagAwIBAgIQa/7ejstqRGm1NLg7U226wDANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDEwloaXBwby5ydW4wHhcNMjIxMDI0MTMxMTQ0WhcNMjMxMDI0MTMyMTQ0WjAUMRIwEAYDVQQDEwloaXBwby5ydW4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDqbd8MV8uulzJN4sZXcwnk7PVHF9NgOmmUdeUWEGknvhDE/HJJGaz6k3IE0mcoqC2R6iUSU2/pVTMDqHba5Fnkt999OboIM5EQNXHj2jGH4IuotrL3DrO6KapOHIb7VkpJb6FvPD4zMNQLNj7SMAsuw9uagJen/PjzaK8Duc7YEgE5zvPhAyvjfglxKPaYuEKLPToBwLQJU+mVrwe7+xcArd6GWMoi7/Kp0ipVkL89oWe2RRjWeJX0P0j6exOA7RBPfzWUabwIau8s7pR606BnwrBh2ok2bNfFWSB/TlbkJjMS5s2dK7uFaXs4hYQ9qBOVQqhzBAQuTFqCVlL5K5bJAgMBAAGjfDB6MA4GA1UdDwEB/wQEAwIFoDAJBgNVHRMEAjAAMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAfBgNVHSMEGDAWgBTFFcUGyRGSyfmP3+JtqXYHeaHerjAdBgNVHQ4EFgQUxRXFBskRksn5j9/ibal2B3mh3q4wDQYJKoZIhvcNAQELBQADggEBAGK4JveShg31LDUf2wEssjBxDXDoedSlPu8I1ahdsfDt1k0IS1dk842PLPxXwOiAzp4uCb5kQJilM41xFqmZTGzQR+5j+aUI1qONwhakPUckllpoV7jlrqpGn63SPaZdYjU93krKU65jIZQAA87ziEMTtEelY7cvw01bAE1Nr+SvO6QBXCVX2gfV62FU7vUN7KA4Anwk1FP1yWQpbe46irf948sQ9GRXYToTA6eh5ccu1euB70+JK5/tcH2mWv6SzenIuvG5HEHX0jxzf65Hgj/YPrh1bXrJAjujx4XUlF/39go0CXNNaCTQ0w3sjlV1sdKhQEllXrw0jMHf9Gt5oYk='


//------------  log analytics-----------

resource logsRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'logs'
  location: 'westeurope'
}

module logAnalytics 'modules/logAnalyticsWorkspace.bicep' = {
  scope: logsRG
  name: 'la-deployment'
}


//------------ vwan, hub, P2S and firewall-----------

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
    hubName: hubName
  }
}

module firewall 'modules/firewall.bicep' = {
  scope: wanRG
  name: 'firewall-deployment'
  params: {
    hubId: hubs.outputs.hubResourceId
    laResourceId: logAnalytics.outputs.laResourceId
    dnsServerIpAdr: dns.outputs.indboundIpAdr
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

module vpnConfig 'modules/p2s.bicep' = {
  scope: wanRG
  name: 'vpnConfig-deployment'
  params: {
    vpnRootCertificateName: 'vpnCertTst'
    publicCertData: p2SPublicCertData
    virtualHubId: hubs.outputs.hubResourceId
  }
}

resource dnsRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'dns'
  location: 'westeurope'
} 

module dns 'modules/dns.bicep' = {
  scope: dnsRG
  name: 'dns-deployment'
  params:{
    
  }
}
