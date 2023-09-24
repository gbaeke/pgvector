param parPrefix string
param parLocation string

// log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${parPrefix}-la'
  location: parLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// app insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${parPrefix}-ai'
  location: parLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: logAnalyticsWorkspace.id    
  }
}

// deploy container apps environment
resource acaEnv 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${parPrefix}-aca-env'
  location: parLocation
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: appInsights.properties.InstrumentationKey
      }
    }
    daprAIConnectionString: appInsights.properties.ConnectionString
    
  }
}


// deploy ui as a container app
resource webui 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: '${parPrefix}-webui'
  location: parLocation
  properties: {
    managedEnvironmentId: acaEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 6333

      }
    }
    template: {
      containers: [
        {
          image: 'qdrant/qdrant'
          name: 'qdrant'
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }

    }

  }
}

