param appBuildersGroup string

param location string = resourceGroup().location
param defaultResourceName string

var azureAdSettings = [
  {
    name: 'ClientId'
    value: '52547135-6beb-44d4-8d4f-0fc5a3366807'
  }
  {
    name: 'Instance'
    value: 'https://login.microsoftonline.com/'
  }
  {
    name: 'Domain'
    value: '4DotNet.nl'
  }
  {
    name: 'Authority'
    value: 'https://login.microsoftonline.com/5992a427-2b8e-43f2-a467-7fdc724be4bd'
  }
  {
    name: 'TenantId'
    value: '5992a427-2b8e-43f2-a467-7fdc724be4bd'
  }
  {
    name: 'ValidateAuthority'
    value: true
  }
  {
    name: 'ApiScope'
    value: 'api://roulette/management'
  }
  {
    name: 'Audience'
    value: 'api://roulette'
  }
]

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${defaultResourceName}-log'
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource webPubSub 'Microsoft.SignalRService/webPubSub@2023-08-01-preview' = {
  name: '${defaultResourceName}-wps'
  location: location
  sku: {
    name: 'Free_F1'
    tier: 'Free'
  }
  kind: 'WebPubSub'
  properties: {}
  resource hub 'hubs@2023-08-01-preview' = {
    name: 'whackamole'
    properties: {
      anonymousConnectPolicy: 'allow'
    }
  }

}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${defaultResourceName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource redisCache 'Microsoft.Cache/redis@2023-08-01' = {
  name: '${defaultResourceName}-cache'
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
    enableNonSslPort: false
    publicNetworkAccess: 'Enabled'
  }
}

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: '${defaultResourceName}-appcfg'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  resource adConfigurationValue 'keyValues@2023-03-01' = [for adSetting in azureAdSettings: {
    name: 'AzureAD:${adSetting.name}'
    properties: {
      contentType: 'text/plain'
      value: adSetting.value
    }
  }]
  resource webPubSubConfigurationValue 'keyValues@2023-03-01' = {
    name: 'AzureServices:WebPubSubEndpoint'
    properties: {
      contentType: 'text/plain'
      value: 'https://${webPubSub.properties.hostName}'
    }
  }
  resource webPubSubHubConfigurationValue 'keyValues@2023-03-01' = {
    name: 'AzureServices:WebPubSubHub'
    properties: {
      contentType: 'text/plain'
      value: 'whackamole'
    }
  }
  resource appInsightsConnectionStringConfiguration 'keyValues@2023-03-01' = {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    properties: {
      contentType: 'text/plain'
      value: applicationInsights.properties.ConnectionString
    }
  }
  resource redisCacheEndpointConfiguration 'keyValues@2023-03-01' = {
    name: 'Cache:Endpoint'
    properties: {
      contentType: 'text/plain'
      value: redisCache.properties.hostName
    }
  }
  resource redisCacheKeyConfiguration 'keyValues@2023-03-01' = {
    name: 'Cache:Secret'
    properties: {
      contentType: 'text/plain'
      value: redisCache.listKeys().primaryKey
    }
  }
}

resource containerAppEnvironments 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: '${defaultResourceName}-env'
  location: location
  properties: {
    daprAIInstrumentationKey: applicationInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

resource appConfigurationDataReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '	516239f1-63e1-4d78-a4de-a74fb236a071'
}
module appConfigurationDataReaderRoleAssignment 'roleAssignment.bicep' = {
  name: 'appConfigurationDataReaderRoleAssignment'
  params: {
    principalId: appBuildersGroup
    roleDefinitionId: appConfigurationDataReaderRoleDefinition.id
    principalType: 'Group'
  }
}
