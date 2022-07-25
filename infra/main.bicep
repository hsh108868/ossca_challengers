param name string
param loc string = 'krc'
param location string = resourceGroup().location
param sku string = 'Consumption'
param sc int = 0
param publisherEmail string
param publisherName string

output rn string = rg

var rg = 'rg-${name}-${loc}'
var fncappname = 'fncapp-${uniqueString(name)}-${loc}'

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: 'apim-${name}-${loc}'
  location: location
  sku: {
    capacity: sc
    name: sku
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource azureFunction 'Microsoft.Web/sites@2022-03-01' = {
  name: fncappname
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: servicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.id
        }
      ]
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'st${uniqueString(name)}${loc}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'cs-${name}-${loc}'
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  properties: {
    reserved: false
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'cs-${name}-${loc}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'wrkspc-${name}-${loc}'
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}
