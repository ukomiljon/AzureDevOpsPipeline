@description('Name of the App Service')
param appServiceName string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Location of the resources')
param location string = resourceGroup().location

@description('SKU of the App Service Plan')
param skuName string = 'B1'

@description('Tier of the App Service Plan')
param tier string = 'Basic'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: tier
    capacity: 1
  }
  properties: {
    reserved: false
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource webAppSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  parent: webApp  
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output appServiceUrl string = 'https://${webApp.properties.defaultHostName}'
output stagingSlotUrl string = 'https://${webAppSlot.properties.defaultHostName}'
