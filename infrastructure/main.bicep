targetScope = 'subscription'

@allowed([ 'tst', 'prd' ])
param runtimeEnvironment string
param appBuildersGroup string

param location string = deployment().location

var defaultResourceName = 'wam-int-${runtimeEnvironment}'
var resourceGroupName = '${defaultResourceName}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2018-05-01' = {
  name: resourceGroupName
  location: location
}

module resources 'resources.bicep' = {
  name: 'resources'
  scope: resourceGroup
  params: {
    appBuildersGroup: appBuildersGroup
    location: location
    defaultResourceName: defaultResourceName
  }
}
