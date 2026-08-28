// Everything inside the resource group. Kept separate from main.bicep because
// azd requires a subscription-scoped entry point, while these resources are
// resource-group scoped.
targetScope = 'resourceGroup'

param location string
param allowedIpAddressRange string
param cartApiImage string
param tags object

var uniqueSuffix = uniqueString(resourceGroup().id)
var managedEnvironmentName = 'cae-gh600lab-${uniqueSuffix}'
var containerAppName = 'ca-cart-${uniqueSuffix}'

module managedEnvironment 'br/public:avm/res/app/managed-environment:0.15.0' = {
  name: 'deploy-cart-environment'
  params: {
    name: managedEnvironmentName
    location: location
    // No Log Analytics workspace and no Azure Monitor destination. Log
    // ingestion is billed per GB, and this lab reads logs through
    // `az containerapp logs` instead.
    publicNetworkAccess: 'Enabled'
    tags: tags
    zoneRedundant: false
  }
}

module cartApi 'br/public:avm/res/app/container-app:0.23.0' = {
  name: 'deploy-cart-api'
  params: {
    name: containerAppName
    location: location
    environmentResourceId: managedEnvironment.outputs.resourceId
    containers: [
      {
        name: 'cart-api'
        image: cartApiImage
        env: [
          {
            name: 'PORT'
            value: '8000'
          }
        ]
        probes: [
          {
            type: 'Readiness'
            httpGet: {
              path: '/healthz'
              port: 8000
              scheme: 'HTTP'
            }
            periodSeconds: 10
          }
          {
            type: 'Startup'
            failureThreshold: 30
            httpGet: {
              path: '/healthz'
              port: 8000
              scheme: 'HTTP'
            }
            periodSeconds: 1
            timeoutSeconds: 2
          }
        ]
        // Smallest valid CPU and memory pairing on the Consumption plan.
        resources: {
          cpu: json('0.25')
          memory: '0.5Gi'
        }
      }
    ]
    ingressAllowInsecure: false
    ingressExternal: true
    ingressTargetPort: 8000
    ingressTransport: 'auto'
    ipSecurityRestrictions: [
      {
        name: 'allowed-client'
        action: 'Allow'
        description: 'Limit the unauthenticated lab API to the reviewed client CIDR.'
        ipAddressRange: allowedIpAddressRange
      }
    ]
    // Scale to zero when idle. This is the difference between a few dollars a
    // month and effectively nothing: an app with no running replica is not
    // billed for compute. The cost is a cold start on the first request.
    scaleSettings: {
      minReplicas: 0
      maxReplicas: 1
    }
    tags: tags
  }
}

output cartApiName string = cartApi.outputs.name
output cartApiUrl string = 'https://${cartApi.outputs.fqdn}'
output managedEnvironmentName string = managedEnvironment.outputs.name
