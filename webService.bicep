param appServiceName string  // Default value
param resourceGroupName string // Default value
param action string = 'start'  // Default value
param newAppServicePlan string = '' // Only needed for "change" action  

resource appServiceAction 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (action == 'create' || action == 'change') {
  name: 'createOrChangeWebService'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.9.1'
    scriptContent: 'if [ "${action}" == "create" ]; then\n  az webapp create --name ${appServiceName} --resource-group ${resourceGroupName} --plan ${newAppServicePlan}\nelif [ "${action}" == "change" ]; then\n  az webapp update --name ${appServiceName} --resource-group ${resourceGroupName} --plan ${newAppServicePlan}\nfi'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
  }
}

resource startAppService 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (action == 'start' && action != 'mock') {
  name: 'startWebService'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.9.1'
    scriptContent: 'az webapp start --name ${appServiceName} --resource-group ${resourceGroupName}'
    timeout: 'PT15M'
    retentionInterval: 'P1D'
  }
}

resource stopAppService 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (action == 'stop' && action != 'mock') {
  name: 'stopWebService'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.9.1'
    scriptContent: 'az webapp stop --name ${appServiceName} --resource-group ${resourceGroupName}'
    timeout: 'PT15M'
    retentionInterval: 'P1D'
  }
}

resource deleteAppService 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (action == 'delete' && action != 'mock') {
  name: 'deleteWebService'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.9.1'
    scriptContent: 'az webapp delete --name ${appServiceName} --resource-group ${resourceGroupName} --yes'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
  }
}

// For the mock action, you can just return a success message without doing any actual work
resource mockAction 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (action == 'mock') {
  name: 'mockWebServiceAction-${uniqueString(resourceGroup().id, deployment().name)}'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.9.1'
    scriptContent: 'echo "Mock action executed for ${action}. No web service operation performed."'
    timeout: 'PT5M'
    retentionInterval: 'P1D'
  }
}

output actionStatus string = '${action} Web Service operation completed.'
