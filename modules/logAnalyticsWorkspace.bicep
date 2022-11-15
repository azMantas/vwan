


resource la 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'la-central'
  location: resourceGroup().location
  properties:{
    sku:{
      name: 'PerGB2018'
    }
  }
}


output laResourceId string = la.id
